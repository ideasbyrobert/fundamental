import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("a refused composition cannot complete a save or close action",
          arguments: ["finish", "save", "close"])
    func commitRefusal(_ action: String) async throws
    {
        let limits = try #require(DocumentHistoryLimits(
            transactions: 1, retainedUTF16Units: 1
        ))
        let window = try WritingTestWindow(session: DocumentSession(
            state: WritingTestDocument("AB").state, historyLimits: limits,
            initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        let before = window.storage
        window.mark("draft")
        #expect(window.view.hasMarkedText())
        switch action
        {
        case "save":
            #expect(!(await window.controller.performSave(
                choosingLocation: false, closing: false
            )))
        case "close":
            #expect(!window.controller.mayClose())
        default:
            #expect(!window.controller.bridge.finishComposition(
                in: window.view
            ))
        }
        #expect(window.storage == before)
        #expect(!window.session.isDirty)
        #expect(!window.view.hasMarkedText())
        #expect(window.controller.documentWindow.isVisible)
        try window.expect("AB", selection: NSRange(location: 0, length: 0))
    }
}
