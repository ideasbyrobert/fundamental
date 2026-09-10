import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("native scopes preserve every trait combination and block role",
          arguments: [0, 1, 2])
    func nativeScopeAppearance(_ form: Int) throws
    {
        let scopes = try WritingScopeFixture.scopes()[form]
        for bits in 0 ..< (1 << WritingInlineFixture.traits.count)
        {
            let traits = Set(WritingInlineFixture.traits.enumerated().compactMap
                { index, trait in bits & (1 << index) == 0 ? nil : trait })
            let attributes = SemanticRunAttributes.scoped(
                traits: traits, scopes: scopes
            )
            let blocks = try WritingInlineFixture.roles([
                SemanticRun(text: "Ae\u{301}😀Z", attributes: attributes)
            ])
            let source = try WritingTestDocument(blocks: blocks)
            let projection = try source.projection()
            let native = try #require(WritingTextPresentation(projection))
            #expect(native.text.string.utf16.elementsEqual(
                projection.text.utf16
            ))
            var ordinal = 0
            for (index, block) in blocks.enumerated()
            {
                let base = try #require(WritingTypography.attributes(
                    for: block, ordinal: &ordinal
                )?[.font] as? NSFont)
                let actual = native.text.attributes(
                    at: projection.map.spans[index].range.location,
                    effectiveRange: nil
                )
                WritingScopeFixture.expect(form, in: actual)
                try WritingInlineFixture.expect(traits, in: actual, base: base)
                let span = projection.map.spans[index]
                if span.separatorLength > 0
                {
                    let separator = native.text.attributes(
                        at: NSMaxRange(span.range), effectiveRange: nil
                    )
                    #expect(separator[.link] == nil)
                    #expect(separator[.languageIdentifier] == nil)
                }
            }
            WritingScopeFixture.expect(form, in: native.typingAttributes)
            #expect(projection.snapshot.snapshot.document ==
                source.state.snapshot.document)
        }
    }

    @Test("native link activation is handled without changing the document")
    func nativeScopeLinkActivation() throws
    {
        let window = try WritingTestWindow(session: DocumentSession(
            state: WritingTestDocument(blocks: [.paragraph(SemanticParagraph(
                runs: [SemanticRun(text: "Link", attributes: .scoped(
                    traits: [], scopes: WritingScopeFixture.scopes()[0]
                ))]
            ))]).state
        ))
        defer
        {
            window.close()
        }
        let before = window.storage
        let bridge = window.controller.bridge
        #expect(bridge.responds(to: NSSelectorFromString(
            "textView:clickedOnLink:atIndex:"
        )))
        #expect(bridge.textView(window.view,
            clickedOnLink: WritingScopeFixture.link, at: 0))
        #expect(!window.view.isAutomaticLinkDetectionEnabled)
        #expect(!window.view.isAutomaticDataDetectionEnabled)
        #expect(window.storage == before)
    }
}
