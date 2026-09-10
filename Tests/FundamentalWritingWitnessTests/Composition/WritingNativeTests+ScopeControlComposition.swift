import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("formatting commits scoped preedit before changing its traits")
    func nativeScopeControlComposition() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.select(1)
        try window.chooseInline(.strong)
        try WritingScopeFixture.choose(2, in: window)
        let before = window.storage
        window.mark("xy", selecting: NSRange(location: 0, length: 2))
        let italic = try window.formatChoice("Italic", group: "Text Style")
        #expect(window.controller.validateUserInterfaceItem(italic))
        #expect(italic.state == .off)
        #expect(window.storage == before && window.view.hasMarkedText())
        try window.performFormat(italic)
        try window.expect("AxyB", selection: NSRange(location: 1, length: 2))
        #expect(window.session.history.undo.count == 2)
        let runs = try WritingInlineFixture.runs(window.session.document)
        #expect(try runs.contains(WritingScopeFixture.run(
            "xy", form: 2, traits: [.strong, .emphasis]
        )))
        window.view.undoCanonicalEdit(nil)
        try window.expectInline(.strong, .on)
        try window.expectInline(.emphasis, .off)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            before.state.snapshot.document.content)
        WritingScopeFixture.expect(2, in: window.view.typingAttributes)
    }
}
