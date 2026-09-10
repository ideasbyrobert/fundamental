import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("native Unicode replacement inherits only the first replaced scope")
    func nativeScopeReplacement() throws
    {
        let runs = [
            try WritingScopeFixture.run("Ae\u{301}", form: 0,
                                         traits: [.strong]),
            try WritingScopeFixture.run("😀Z", form: 1, traits: [.emphasis])
        ]
        let source = try WritingTestDocument(blocks: [.paragraph(
            SemanticParagraph(runs: runs)
        )])
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state
        ))
        let board = NSPasteboard.withUniqueName()
        defer
        {
            board.releaseGlobally()
            window.close()
        }
        window.select(1, 4)
        #expect(board.setString("N", forType: .string))
        window.view.paste(board)
        try window.expect("ANZ", selection: NSRange(location: 2, length: 0))
        #expect(try WritingInlineFixture.runs(window.session.document) == [
            try WritingScopeFixture.run("A", form: 0, traits: [.strong]),
            try WritingScopeFixture.run("N", form: 0, traits: [.strong]),
            try WritingScopeFixture.run("Z", form: 1, traits: [.emphasis])
        ])
        #expect(window.session.history.undo.count == 1)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            source.state.snapshot.document.content)
        window.view.deleteBackward(nil)
        try window.expect("AZ", selection: NSRange(location: 1, length: 0))
        #expect(try WritingInlineFixture.runs(window.session.document) == [
            try WritingScopeFixture.run("A", form: 0, traits: [.strong]),
            try WritingScopeFixture.run("Z", form: 1, traits: [.emphasis])
        ])
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            source.state.snapshot.document.content)
    }
}
