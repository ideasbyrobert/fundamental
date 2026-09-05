import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingAcceptanceScenario
{
    func rebuildAndClose() throws
    {
        let before = window.storage
        let replacement = try WritingTestWindow(session: window.session)
        defer
        {
            replacement.close()
        }
        #expect(replacement.storage == before)
        try replacement.expect("Aé! 👋", selection: NSRange(
            location: 3, length: 0
        ))
        replacement.controller.documentWindow.performClose(nil)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        #expect(replacement.controller.documentWindow.isVisible)
        #expect(replacement.storage == before)
        let discarded = try WritingTestWindow(
            session: window.session, decision: { .discard }
        )
        defer
        {
            discarded.close()
        }
        discarded.controller.documentWindow.performClose(nil)
        #expect(!discarded.controller.documentWindow.isVisible)
        #expect(discarded.storage == before)
        try expect("Aé! 👋", 3, revision: 10, generation: 12, undo: 4)
    }
}
