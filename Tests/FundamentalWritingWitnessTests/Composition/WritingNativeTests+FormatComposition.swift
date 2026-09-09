import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("Format validates preedit without committing then applies in order")
    func formatMenuCommitsCompositionInOrder() throws
    {
        let window = try WritingTestWindow(styles: [.body], texts: [""])
        defer
        {
            window.close()
        }
        let original = window.session.document.content
        window.mark("題名")
        let preedit = window.storage
        let heading = try window.formatChoice("Heading",
                                              group: "Paragraph Style")
        #expect(window.controller.validateUserInterfaceItem(heading))
        #expect(window.storage == preedit)
        #expect(window.view.hasMarkedText())
        try window.performFormat(heading)
        #expect(!window.view.hasMarkedText())
        #expect(window.view.string == "題名")
        #expect(window.styles == [.heading])
        #expect(window.session.history.undo.count == 2)
        window.view.undoCanonicalEdit(nil)
        #expect(window.styles == [.body])
        #expect(window.view.string == "題名")
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == original)
        #expect(!window.session.isDirty)
    }
}
