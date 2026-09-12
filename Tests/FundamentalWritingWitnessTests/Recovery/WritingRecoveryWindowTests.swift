import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

@MainActor
@Suite("Recovery window lifecycle without desktop input", .serialized)
struct WritingRecoveryWindowTests
{
    @Test("explicit discard waits for recovery retirement before closing")
    func discard() async throws
    {
        let directory = try WritingRecoveryTests.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WritingRecoveryStore(directory: directory)
        let owner = WritingFileOwner(session: DocumentSession(
            state: try WritingTestDocument("Writing").state
        ))
        let candidate = WritingWindowController(owner: owner,
                                                 confirmDiscard: { .discard })
        let controller = try #require(candidate)
        defer { controller.documentWindow.close() }
        controller.installRecovery(using: store)
        let recovery = try #require(owner.recovery)
        let record = try #require(recovery.prepareSave())
        await recovery.checkpoint(record)
        #expect(!controller.mayClose())
        let closing = try #require(controller.closeTask)
        #expect(await closing.value)
        #expect(controller.discardApproved)
        #expect(recovery.stopped)
        #expect(try await store.catalog().records.isEmpty)
    }

    @Test("new typing during an awaited discard stays open and recoverable")
    func editDuringDiscard() async throws
    {
        let directory = try WritingRecoveryTests.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WritingRecoveryStore(directory: directory)
        let owner = WritingFileOwner(session: DocumentSession(
            state: try WritingTestDocument("A").state
        ))
        let candidate = WritingWindowController(owner: owner,
                                                 confirmDiscard: { .discard })
        let controller = try #require(candidate)
        defer { controller.documentWindow.close() }
        controller.installRecovery(using: store)
        let previous = try #require(owner.recovery)
        controller.textView.setSelectedRange(NSRange(location: 1, length: 0))
        #expect(!controller.mayClose())
        let closing = try #require(controller.closeTask)
        controller.textView.insertText("B", replacementRange:
            controller.textView.selectedRange())
        #expect(await !closing.value)
        #expect(!controller.discardApproved)
        #expect(controller.textView.string == "AB")
        #expect(owner.session.isDirty)
        let recovery = try #require(owner.recovery)
        #expect(recovery.identifier != previous.identifier)
        #expect(!recovery.stopped)
        let snapshot = try #require(WritingProjection(owner.session.state))
        let record = try #require(recovery.capture(snapshot.snapshot))
        await recovery.checkpoint(record)
        #expect(try await store.catalog().recoverable.first?.identifier ==
            recovery.identifier)
    }
}
