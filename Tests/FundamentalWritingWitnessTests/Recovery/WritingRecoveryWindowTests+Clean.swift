import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingRecoveryWindowTests
{
    @Test("clean close flushes the latest undo state before closing the window")
    func cleanClose() async throws
    {
        let directory = try WritingRecoveryTests.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WritingRecoveryStore(directory: directory)
        let owner = WritingFileOwner(session: DocumentSession(
            state: try WritingTestDocument("A").state, initiallySaved: true
        ))
        let controller = try #require(WritingWindowController(owner: owner))
        defer { controller.documentWindow.close() }
        controller.installRecovery(using: store)
        let recovery = try #require(owner.recovery)
        controller.textView.setSelectedRange(NSRange(location: 1, length: 0))
        controller.textView.insertText("B", replacementRange:
            controller.textView.selectedRange())
        let checkpoint = try #require(recovery.prepareSave())
        await recovery.checkpoint(checkpoint)
        controller.bridge.move(.undo, in: controller.textView)
        #expect(!owner.session.isDirty)
        #expect(!controller.mayClose())
        let closing = try #require(controller.closeTask)
        #expect(await closing.value)
        let catalog = try await store.catalog()
        #expect(catalog.recoverable.isEmpty)
        #expect(catalog.records.first?.snapshot.snapshot.document ==
            owner.session.document)
        #expect(catalog.records.first?.requiresRecovery == false)
    }
}
