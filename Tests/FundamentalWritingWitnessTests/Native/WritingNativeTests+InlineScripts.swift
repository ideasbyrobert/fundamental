import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("Text script commands are exclusive without dropping other traits")
    func inlineControlsScripts() throws
    {
        let window = try WritingTestWindow("X")
        defer
        {
            window.close()
        }
        window.select(0, 1)
        try window.chooseInline(.strong)
        try window.chooseInline(.superscript)
        try window.chooseInline(.subscriptText)
        try window.expectInline(.strong, .on)
        try window.expectInline(.superscript, .off)
        try window.expectInline(.subscriptText, .on)
        let runs = try WritingInlineFixture.runs(window.session.document)
        #expect(runs == [SemanticRun(text: "X",
                                     traits: [.strong, .subscriptText])])
        window.view.undoCanonicalEdit(nil)
        try window.expectInline(.superscript, .on)
        try window.expectInline(.subscriptText, .off)
    }
}
