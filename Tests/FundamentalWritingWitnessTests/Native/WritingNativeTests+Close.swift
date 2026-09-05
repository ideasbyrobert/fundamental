import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test
    func closeCancellationPreservesWindowAndCanonicalState() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        let before = window.storage
        window.controller.documentWindow.performClose(nil)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        #expect(window.controller.documentWindow.isVisible)
        #expect(window.storage == before)
        let delegate = WritingApplicationDelegate(controller: window.controller)
        #expect(delegate.applicationShouldTerminate(NSApp) == .terminateCancel)
    }

    @Test
    func emptyCanonicalDocumentNeedsNoDiscardDecision() throws
    {
        _ = NSApplication.shared
        let session = DocumentSession(state: try WritingTestDocument().state)
        var asked = 0
        let candidate = WritingWindowController(session: session)
        {
            asked += 1
            return .cancel
        }
        let controller = try #require(candidate)
        controller.documentWindow.animationBehavior = .none
        defer
        {
            controller.documentWindow.delegate = nil
            controller.documentWindow.close()
        }
        #expect(controller.mayClose())
        #expect(asked == 0)
    }

    @Test
    func discardDecisionIsReusedForCloseThenTermination() throws
    {
        _ = NSApplication.shared
        let session = DocumentSession(state: try WritingTestDocument("A").state)
        var asked = 0
        let candidate = WritingWindowController(session: session)
        {
            asked += 1
            return .discard
        }
        let controller = try #require(candidate)
        controller.documentWindow.animationBehavior = .none
        defer
        {
            controller.documentWindow.delegate = nil
            controller.documentWindow.close()
        }
        controller.showWindow(nil)
        controller.documentWindow.performClose(nil)
        #expect(!controller.documentWindow.isVisible)
        let delegate = WritingApplicationDelegate(controller: controller)
        #expect(delegate.applicationShouldTerminate(NSApp) == .terminateNow)
        #expect(asked == 1)
    }
}
