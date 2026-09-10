import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("scope editors finish composition before capturing the target",
          arguments: WritingScopeKind.allCases, [false, true])
    func scopeControlsSheetComposition(_ kind: WritingScopeKind, cancel: Bool)
        async throws
    {
        let source = try WritingTestDocument("AB")
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        window.select(1)
        try window.chooseInline(.strong)
        window.mark("e\u{301}😀", selecting: NSRange(location: 0, length: 4))
        let sheet = try window.openScopeSheet(kind)
        #expect(!window.view.hasMarkedText())
        #expect(window.session.history.undo.count == 1)
        let value = kind == .link ? WritingScopeFixture.link :
            WritingScopeFixture.language
        window.setScopeValue(value, in: sheet)
        try await window.finishScopeSheet(sheet, response: cancel
            ? .alertSecondButtonReturn : .alertFirstButtonReturn)
        try window.expect("Ae\u{301}😀B", selection: NSRange(
            location: 1, length: 4
        ))
        let runs = try WritingInlineFixture.runs(window.session.document)
        let composed = try #require(runs.first { $0.text == "e\u{301}😀" })
        let expected = cancel
            ? SemanticRunAttributes.direct(traits: [.strong])
            : try WritingScopeControlFixture.attributes(value, kind: kind)
        #expect(composed.attributes == expected)
        #expect(window.session.history.undo.count == (cancel ? 1 : 2))
        if !cancel
        {
            window.view.undoCanonicalEdit(nil)
        }
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            source.state.snapshot.document.content)
        #expect(!window.session.isDirty)
        try window.expectInline(.strong, .on)
    }
}
