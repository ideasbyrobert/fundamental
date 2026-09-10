import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("scope sheets preserve exact partial edits and directed selection",
          arguments: WritingScopeKind.allCases, [false, true])
    func scopeControlsSheetEditing(_ kind: WritingScopeKind, toolbar: Bool)
        async throws
    {
        let text = "Ae\u{301}😀Z"
        let run = SemanticRun(text: text, attributes: .scoped(traits: [.strong],
            scopes: try WritingScopeFixture.scopes()[2]))
        let source = try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [run]))
        ], start: 5, end: 1)
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        let sheet = try window.openScopeSheet(kind, toolbar: toolbar)
        let original = kind == .link ? WritingScopeFixture.link :
            WritingScopeFixture.language
        #expect(sheet.field.stringValue.utf16.elementsEqual(original.utf16))
        window.setScopeValue(" \t\n", in: sheet)
        #expect(!sheet.alert.buttons[0].isEnabled)
        let value = " Changed e\u{301} 😀 "
        window.setScopeValue(value, in: sheet)
        #expect(sheet.alert.buttons[0].isEnabled)
        try await window.finishScopeSheet(sheet,
                                          response: .alertFirstButtonReturn)
        let runs = try WritingInlineFixture.runs(window.session.document)
        try #require(runs.count == 3)
        #expect(runs.map(\.text) == ["A", "e\u{301}😀", "Z"])
        #expect(runs.flatMap { Array($0.text.utf16) } == Array(text.utf16))
        #expect(runs.allSatisfy { $0.traits == [.strong] })
        #expect(runs[0].attributes == run.attributes)
        #expect(runs[2].attributes == run.attributes)
        guard case let .scoped(_, .linkAndLanguage(link, language)) =
            runs[1].attributes
        else
        {
            Issue.record("Both scopes must survive a single-scope edit")
            return
        }
        #expect(link.value.utf16.elementsEqual((kind == .link ? value :
            WritingScopeFixture.link).utf16))
        #expect(language.value.utf16.elementsEqual((kind == .language ? value :
            WritingScopeFixture.language).utf16))
        let selection = window.controller.bridge.projection.snapshot.selection
        #expect(selection.range.start.utf16Offset.value == 5)
        #expect(selection.range.end.utf16Offset.value == 1)
        #expect(window.session.history.undo.count == 1)
        #expect(window.controller.documentWindow.firstResponder === window.view)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            source.state.snapshot.document.content)
        #expect(!window.session.isDirty)
        window.view.redoCanonicalEdit(nil)
        #expect(try WritingInlineFixture.runs(window.session.document) == runs)
    }
}
