import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("native traits and terminal typing reconstruct from the session")
    func nativeInlineReconstruction() throws
    {
        let source = try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "Bold", traits: [.strong]),
                SemanticRun(text: " italic", traits: [.emphasis])
            ])), .paragraph(SemanticParagraph(runs: []))
        ])
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state
        ))
        defer
        {
            window.close()
        }
        window.select(window.view.string.utf16.count)
        try WritingInlineFixture.choose(.superscript, in: window)
        let before = window.storage
        window.view.delegate = nil
        window.view.string = "poison"
        window.view.textStorage?.setAttributes([
            .font: NSFont.systemFont(ofSize: 80), .strikethroughStyle: 2
        ], range: NSRange(location: 0, length: 6))
        window.view.delegate = window.controller.bridge
        #expect(window.controller.bridge.project(in: window.view))
        let rebuilt = WritingTextView(usingTextLayoutManager: true)
        let bridge = try #require(WritingNativeBridge(session: window.session))
        #expect(WritingTextConfiguration.apply(to: rebuilt))
        rebuilt.delegate = bridge
        #expect(bridge.project(in: rebuilt))
        let base = try #require(WritingTypography.body[.font] as? NSFont)
        for view in [window.view, rebuilt]
        {
            #expect(view.string == "Bold italic\n")
            let storage = try #require(view.textStorage)
            try WritingInlineFixture.expect([.strong],
                in: storage.attributes(at: 0, effectiveRange: nil), base: base)
            try WritingInlineFixture.expect([.emphasis],
                in: storage.attributes(at: 5, effectiveRange: nil), base: base)
            try WritingInlineFixture.expect([.superscript],
                in: view.typingAttributes, base: base)
        }
        #expect(window.storage == before)
        try WritingWindowGeometry.expectVisibleCaret(window)
    }
}
