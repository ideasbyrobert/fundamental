import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("Text validation observes preedit and formatting follows its commit")
    func inlineControlsComposition() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.select(1)
        try window.chooseInline(.strong)
        let before = window.storage
        window.mark("xy", selecting: NSRange(location: 0, length: 2))
        let italic = try window.formatChoice("Italic", group: "Text Style")
        let bold = try window.formatChoice("Bold", group: "Text Style")
        #expect(window.controller.validateUserInterfaceItem(italic))
        #expect(italic.state == .off)
        #expect(window.controller.validateUserInterfaceItem(bold))
        #expect(bold.state == .on)
        #expect(window.storage == before && window.view.hasMarkedText())
        try window.performFormat(italic)
        try window.expect("AxyB", selection: NSRange(location: 1, length: 2))
        #expect(window.session.history.undo.count == 2)
        let runs = try WritingInlineFixture.runs(window.session.document)
        #expect(runs.contains(SemanticRun(text: "xy",
                                         traits: [.strong, .emphasis])))
        window.view.undoCanonicalEdit(nil)
        try window.expectInline(.strong, .on)
        try window.expectInline(.emphasis, .off)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            before.state.snapshot.document.content)
        try window.expectInline(.strong, .on)
    }
}
