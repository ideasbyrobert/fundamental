import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("explicit scope removal preserves the other scope and content",
          arguments: WritingScopeKind.allCases)
    func scopeControlsSheetRemoval(_ kind: WritingScopeKind) async throws
    {
        let run = SemanticRun(text: "A", attributes: .scoped(traits: [.strong],
            scopes: try WritingScopeFixture.scopes()[2]))
        let source = try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [run]))
        ], start: 0, end: 1)
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        let sheet = try window.openScopeSheet(kind)
        window.setScopeValue("", in: sheet)
        #expect(!sheet.alert.buttons[0].isEnabled)
        #expect(sheet.alert.buttons[2].isEnabled)
        try await window.finishScopeSheet(sheet,
                                          response: .alertThirdButtonReturn)
        let changed = try #require(WritingInlineFixture.runs(
            window.session.document
        ).first)
        #expect(changed.text == "A" && changed.traits == [.strong])
        let remaining = try WritingScopeFixture.scopes()[kind == .link ? 1 : 0]
        #expect(changed.attributes == .scoped(traits: [.strong],
                                             scopes: remaining))
        #expect(window.session.history.undo.count == 1)
        #expect(window.view.selectedRange() == NSRange(location: 0, length: 1))
        let absent = try window.openScopeSheet(kind)
        #expect(absent.field.stringValue.isEmpty)
        #expect(!absent.alert.buttons[0].isEnabled)
        #expect(!absent.alert.buttons[2].isEnabled)
        try await window.finishScopeSheet(absent,
                                          response: .alertSecondButtonReturn)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            source.state.snapshot.document.content)
        #expect(!window.session.isDirty)
    }
}
