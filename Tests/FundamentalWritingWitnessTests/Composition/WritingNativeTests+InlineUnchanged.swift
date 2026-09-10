import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("equal spelling with changed traits is a real native edit")
    func nativeInlineSameSpelling() throws
    {
        let source = try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "A", traits: [.emphasis]),
                SemanticRun(text: "B", traits: [.underline])
            ]))
        ], start: 0, end: 2)
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state
        ))
        defer
        {
            window.close()
        }
        let before = window.storage
        window.mark("AB")
        #expect(window.storage == before)
        window.commit("AB")
        #expect(window.session.history.undo.count == 1)
        #expect(try WritingInlineFixture.runs(window.session.document) == [
            SemanticRun(text: "AB", traits: [.emphasis])
        ])
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            source.state.snapshot.document.content)
    }

    @Test("empty and cancelled composition retain explicit typing intent")
    func nativeInlineEmpty() throws
    {
        let window = try WritingTestWindow()
        defer
        {
            window.close()
        }
        try WritingInlineFixture.choose(.strong, in: window)
        let before = window.storage
        window.mark("draft")
        window.view.cancelOperation(nil)
        #expect(window.storage == before)
        window.mark("draft")
        window.mark("")
        #expect(window.storage == before && !window.view.hasMarkedText())
        window.commit("X")
        let runs = try WritingInlineFixture.runs(window.session.document)
        #expect(runs.first?.text == "X" && runs.first?.traits == [.strong])
        #expect(window.session.history.undo.count == 1)
    }
}
