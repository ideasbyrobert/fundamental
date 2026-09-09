import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test
    func codeLanguageSheetPreservesExactLabelsAndCanonicalUndo() async throws
    {
        let source = "A\r\ne\u{301}😀"
        let fixture = try WritingCodeFixture.document(source, tagged: true)
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        window.select(7)
        let original = window.session.document.content
        let sheet = try window.openLanguageSheet()
        window.setLanguage("  ", in: sheet)
        #expect(sheet.alert.buttons[0].isEnabled == false)
        let value = " Swift e\u{301} 😀 "
        window.setLanguage(value, in: sheet)
        #expect(sheet.alert.buttons[0].isEnabled)
        try await window.finishLanguageSheet(sheet,
                                             response: .alertFirstButtonReturn)
        guard case let .code(.languageTagged(code)) =
            window.session.document.content.blocks[1].block
        else
        {
            Issue.record("Expected the edited code language")
            return
        }
        #expect(code.language.value.utf16.elementsEqual(value.utf16))
        #expect(code.runs.map(\.text).joined().utf16
            .elementsEqual(source.utf16))
        #expect(window.session.history.undo.count == 1)
        #expect(window.controller.documentWindow.firstResponder === window.view)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == original)
        #expect(!window.session.isDirty)
        window.view.redoCanonicalEdit(nil)
        let clearing = try window.openLanguageSheet()
        #expect(clearing.field.stringValue.utf16.elementsEqual(value.utf16))
        window.setLanguage("", in: clearing)
        #expect(clearing.alert.buttons[0].isEnabled)
        try await window.finishLanguageSheet(clearing,
                                             response: .alertFirstButtonReturn)
        try WritingCodeFixture.expect(window.session.document.content
            .blocks[1].block, text: source, tagged: false)
        #expect(window.session.history.undo.count == 2)
    }

    @Test
    func codeLanguageSheetRefusesAStaleSelection() async throws
    {
        let fixture = try WritingCodeFixture.document("A", tagged: true)
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        window.select(7)
        let sheet = try window.openLanguageSheet()
        window.setLanguage("Changed", in: sheet)
        let proposal = try #require(WritingSelectionProposal(
            ranges: [NSRange(location: 0, length: 0)],
            in: window.controller.bridge.projection
        ))
        window.session.submit(proposal.command)
        window.controller.bridge.project(in: window.view)
        let current = window.storage
        try await window.finishLanguageSheet(sheet,
                                             response: .alertFirstButtonReturn)
        #expect(window.storage == current)
        #expect(window.view.selectedRange() == NSRange(location: 0, length: 0))
        #expect(!window.session.isDirty)
    }
}
