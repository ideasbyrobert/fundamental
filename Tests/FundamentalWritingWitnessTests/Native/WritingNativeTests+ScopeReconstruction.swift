import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("scoped text and terminal intent reconstruct from canonical state")
    func nativeScopeReconstruction() throws
    {
        let runs = [try WritingScopeFixture.run("Link", form: 0),
                    try WritingScopeFixture.run(" язык", form: 1),
                    try WritingScopeFixture.run(" Both", form: 2)]
        let source = try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: runs)),
            .paragraph(SemanticParagraph(runs: []))
        ])
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state
        ))
        defer
        {
            window.close()
        }
        window.select(window.view.string.utf16.count)
        try WritingScopeFixture.choose(2, in: window)
        try WritingInlineFixture.choose(.superscript, in: window)
        let before = window.storage
        window.view.delegate = nil
        window.view.string = "poison"
        let poison: [NSAttributedString.Key: Any] = [
            .link: "https://foreign.invalid", .languageIdentifier: "zz",
            .font: NSFont.systemFont(ofSize: 80)
        ]
        window.view.textStorage?.setAttributes(poison,
            range: NSRange(location: 0, length: 6))
        window.view.typingAttributes = poison
        window.view.delegate = window.controller.bridge
        #expect(window.controller.bridge.project(in: window.view))
        let rebuilt = WritingTextView(usingTextLayoutManager: true)
        let bridge = try #require(WritingNativeBridge(session: window.session))
        #expect(WritingTextConfiguration.apply(to: rebuilt))
        rebuilt.delegate = bridge
        #expect(bridge.project(in: rebuilt))
        for view in [window.view, rebuilt]
        {
            #expect(view.string == "Link язык Both\n")
            let storage = try #require(view.textStorage)
            for (form, offset) in [0, 4, 9].enumerated()
            {
                WritingScopeFixture.expect(form, in: storage.attributes(
                    at: offset, effectiveRange: nil
                ))
            }
            WritingScopeFixture.expect(2, in: view.typingAttributes)
            let base = try #require(WritingTypography.body[.font] as? NSFont)
            try WritingInlineFixture.expect([.superscript],
                in: view.typingAttributes, base: base)
        }
        #expect(window.storage == before)
        try WritingWindowGeometry.expectVisibleCaret(window)
    }
}
