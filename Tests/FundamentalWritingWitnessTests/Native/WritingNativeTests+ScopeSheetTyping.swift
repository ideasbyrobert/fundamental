import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("scope editors set future prose and code without content history",
          arguments: [CanonicalBlockStyle.body, .monostyled])
    func scopeControlsSheetTyping(_ style: CanonicalBlockStyle) async throws
    {
        let window = try WritingTestWindow(styles: [style], texts: [""])
        let board = NSPasteboard.withUniqueName()
        defer
        {
            board.releaseGlobally()
            window.close()
        }
        try window.chooseInline(.strong)
        let original = window.session.document
        for kind in WritingScopeKind.allCases
        {
            let sheet = try window.openScopeSheet(kind, toolbar: kind == .link)
            let value = kind == .link ? WritingScopeFixture.link :
                WritingScopeFixture.language
            window.setScopeValue(value, in: sheet)
            try await window.finishScopeSheet(sheet,
                                              response: .alertFirstButtonReturn)
            #expect(window.session.document == original)
            #expect(window.session.history.undo.isEmpty)
            #expect(!window.session.isDirty)
        }
        try window.key("x", code: 7)
        #expect(board.setString("e\u{301}😀", forType: .string))
        window.view.paste(board)
        try window.key("\r", code: 36)
        try window.key("y", code: 16)
        try window.expect("xe\u{301}😀\ny", selection: NSRange(
            location: 7, length: 0
        ))
        let expected = SemanticRunAttributes.scoped(traits: [.strong],
            scopes: try WritingScopeFixture.scopes()[2])
        let runs = try WritingInlineFixture.runs(window.session.document)
        #expect(runs.filter { !$0.text.isEmpty }.allSatisfy
            { $0.attributes == expected })
        #expect(window.session.history.undo.count == 4)
        #expect(window.styles.allSatisfy { $0 == style })
        for _ in 0 ..< 4
        {
            window.view.undoCanonicalEdit(nil)
        }
        #expect(window.session.document.content == original.content)
        #expect(!window.session.isDirty)
        try window.key("z", code: 6)
        let retained = try #require(WritingInlineFixture.runs(
            window.session.document
        ).first)
        #expect(retained.text == "z" && retained.attributes == expected)
    }
}
