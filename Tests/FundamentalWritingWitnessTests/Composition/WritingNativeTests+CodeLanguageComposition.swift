import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test
    func codeLanguageRequestCommitsCompositionBeforeCapturingObservation()
        async throws
    {
        let fixture = try WritingCodeFixture.document("", tagged: false)
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
        }
        window.select(7)
        window.mark("題名")
        let item = try window.formatChoice(WritingCodeLanguageMenu.title,
                                           group: "Paragraph Style")
        #expect(window.controller.validateUserInterfaceItem(item))
        #expect(window.view.hasMarkedText())
        let sheet = try window.openLanguageSheet()
        #expect(!window.view.hasMarkedText())
        #expect(window.session.history.undo.count == 1)
        window.setLanguage(WritingCodeFixture.language, in: sheet)
        try await window.finishLanguageSheet(sheet,
                                             response: .alertFirstButtonReturn)
        #expect(window.session.history.undo.count == 2)
        try WritingCodeFixture.expect(window.session.document.content
            .blocks[1].block, text: "題名", tagged: true)
        window.view.undoCanonicalEdit(nil)
        try WritingCodeFixture.expect(window.session.document.content
            .blocks[1].block, text: "題名", tagged: false)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            fixture.state.snapshot.document.content)
    }
}
