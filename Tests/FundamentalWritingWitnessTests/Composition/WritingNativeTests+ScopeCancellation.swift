import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("cancelled and empty composition retain scoped future typing")
    func nativeScopeCancellation() throws
    {
        let window = try WritingTestWindow()
        defer
        {
            window.close()
        }
        try WritingInlineFixture.choose(.strong, in: window)
        try WritingScopeFixture.choose(2, in: window)
        let before = window.storage
        window.mark("draft")
        window.view.cancelOperation(nil)
        #expect(window.storage == before)
        window.mark("draft")
        window.mark("")
        #expect(window.storage == before && !window.view.hasMarkedText())
        WritingScopeFixture.expect(2, in: window.view.typingAttributes)
        window.commit("X")
        let runs = try WritingInlineFixture.runs(window.session.document)
        #expect(runs.filter { !$0.text.isEmpty } == [
            try WritingScopeFixture.run("X", form: 2, traits: [.strong])
        ])
        #expect(window.session.history.undo.count == 1)
    }
}
