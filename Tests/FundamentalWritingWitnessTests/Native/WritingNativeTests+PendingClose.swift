import AppKit
import FundamentalDocument
import FundamentalStorage
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("new typing during save before close keeps the dirty window open")
    func pendingFileClose() async throws
    {
        let fixture = try WritingFileFixture()
        let storage = WritingSuspendedStorage()
        let session = DocumentSession(state: try WritingTestDocument("A").state)
        let receipt = try await DocumentFileStore().save(
            session.document, at: fixture.location, condition: .absent
        )
        let owner = WritingFileOwner(session: session, storage: storage)
        owner.binding = WritingFileBinding(receipt.file)
        let test = try WritingTestWindow(owner: owner, decision: { .save })
        defer
        {
            test.close()
            fixture.remove()
        }
        #expect(!test.controller.mayClose())
        let pending = try #require(test.controller.closeTask)
        await storage.waitForSave()
        #expect(owner.isSaving)
        #expect(test.controller.documentWindow.title.hasSuffix("— Saving"))
        #expect(!test.controller.mayClose())
        let item = NSMenuItem(
            title: "Save",
            action: #selector(WritingWindowController.saveDocument(_:)),
            keyEquivalent: "s"
        )
        #expect(!test.controller.validateUserInterfaceItem(item))
        test.select(1)
        test.view.insertText("B", replacementRange: test.view.selectedRange())
        await storage.continueSave()
        #expect(!(await pending.value))
        #expect(test.controller.documentWindow.isVisible)
        #expect(test.controller.documentWindow.isDocumentEdited)
        #expect(test.controller.documentWindow.title == "Writing.fundamental")
        #expect(test.controller.closeTask == nil)
        #expect(session.isDirty)
        #expect(!owner.isSaving)
        #expect(test.controller.validateUserInterfaceItem(item))
        let stored = try await DocumentFileStore().read(fixture.location)
        #expect(stored.document == receipt.file.document)
        try test.expect("AB", selection: NSRange(location: 2, length: 0))
    }
}
