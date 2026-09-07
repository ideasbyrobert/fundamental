import AppKit
import FundamentalDocument
import FundamentalStorage
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("save before close publishes the current document before closing")
    func saveBeforeClose() async throws
    {
        let fixture = try WritingFileFixture()
        let session = DocumentSession(state: try WritingTestDocument("A").state)
        let test = try WritingTestWindow(session: session, decision: { .save })
        defer
        {
            test.close()
            fixture.remove()
        }
        try await test.controller.fileOwner.save(to: fixture.location)
        test.select(1)
        test.view.insertText("B", replacementRange: test.view.selectedRange())
        var closed = false
        test.controller.didClose = { closed = true }
        #expect(!test.controller.mayClose())
        let pending = try #require(test.controller.closeTask)
        #expect(await pending.value)
        #expect(closed)
        #expect(!test.controller.documentWindow.isVisible)
        #expect(!session.isDirty)
        let stored = try await DocumentFileStore().read(fixture.location)
        #expect(stored.document == session.document)
        #expect(test.controller.closeTask == nil)
    }

    @Test("opening the same bound file reuses its existing window")
    func openingBoundFile() async throws
    {
        let fixture = try WritingFileFixture()
        let test = try WritingTestWindow("A")
        defer
        {
            test.close()
            fixture.remove()
        }
        try await test.controller.fileOwner.save(to: fixture.location)
        let application = WritingApplicationDelegate(
            controller: test.controller
        )
        await application.open(fixture.location)
        #expect(application.controllers.count == 1)
        #expect(application.controllers.first === test.controller)
        #expect(test.controller.documentWindow.isVisible)
    }
}
