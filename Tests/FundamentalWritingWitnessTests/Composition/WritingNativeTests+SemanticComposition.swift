import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("formatting commits preedit first and preserves two undo boundaries")
    func semanticCompositionFormatting() throws
    {
        let window = try WritingTestWindow(styles: [.body], texts: [""])
        defer
        {
            window.close()
        }
        let before = window.session.document
        window.mark("題名")
        #expect(window.session.document == before)
        try window.choose(.title)
        #expect(!window.view.hasMarkedText())
        #expect(window.view.string == "題名")
        #expect(window.styles == [.title])
        #expect(window.session.history.undo.count == 2)
        window.view.undoCanonicalEdit(nil)
        #expect(window.styles == [.body])
        #expect(window.view.string == "題名")
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == before.content)
        #expect(!window.session.isDirty)
    }

    @Test("list preedit changes only presentation and Escape restores markers")
    func semanticCompositionPreview() throws
    {
        let window = try WritingTestWindow(
            styles: [.numbered, .numbered], texts: ["First", ""]
        )
        defer
        {
            window.close()
        }
        window.select(6)
        #expect(window.view.typingAttributes[WritingTypography.marker]
            as? String == "2.")
        let before = window.storage
        window.mark("仮の文")
        #expect(window.view.hasMarkedText())
        #expect(window.storage == before)
        #expect(try window.markerLabels() == ["1.", "2."])
        window.view.cancelOperation(nil)
        #expect(window.view.string == "First\n")
        #expect(window.storage == before)
        #expect(try window.markerLabels() == ["1.", "2."])
    }

    @Test("multiline preedit previews heading continuation without committing")
    func semanticCompositionParagraphs() throws
    {
        let window = try WritingTestWindow(styles: [.title], texts: ["Title"])
        defer
        {
            window.close()
        }
        window.select(5)
        let before = window.storage
        window.mark("\nBody")
        #expect(window.storage == before)
        #expect(window.view.string == "Title\nBody")
        let storage = try #require(window.view.textStorage)
        #expect((storage.attribute(.font, at: 6,
            effectiveRange: nil) as? NSFont)?.pointSize == 20)
        window.commit("\nBody")
        #expect(window.styles == [.title, .body])
        #expect(window.session.history.undo.count == 1)
    }
}
