import AppKit
import FundamentalDocument
import FundamentalStorage
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("preedit arriving during save before close keeps newer content open")
    func pendingSave() async throws
    {
        let fixture = try WritingFileFixture()
        let storage = WritingSuspendedStorage()
        let session = DocumentSession(state: try WritingTestDocument("A").state)
        let receipt = try await DocumentFileStore().save(
            session.document, at: fixture.location, condition: .absent
        )
        let owner = WritingFileOwner(session: session, storage: storage)
        owner.binding = WritingFileBinding(receipt.file)
        let window = try WritingTestWindow(owner: owner, decision: { .save })
        defer
        {
            window.close()
            fixture.remove()
        }
        #expect(!window.controller.mayClose())
        let pending = try #require(window.controller.closeTask)
        await storage.waitForSave()
        window.select(1)
        window.mark("é")
        #expect(window.view.hasMarkedText())
        await storage.continueSave()
        #expect(!(await pending.value))
        #expect(window.controller.documentWindow.isVisible)
        #expect(session.isDirty)
        #expect(!window.view.hasMarkedText())
        try window.expect("Aé", selection: NSRange(location: 2, length: 0))
        let reopened = try await WritingFileOwner.open(fixture.location)
        #expect(WritingProjection(reopened.session.state)?.text == "A")
    }
}
