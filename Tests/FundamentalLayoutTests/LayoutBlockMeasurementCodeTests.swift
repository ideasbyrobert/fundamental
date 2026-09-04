import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutBlockMeasurementTests
{
    @MainActor
    @Test("plain and language code share the exact code measurement form")
    func codeForms() throws
    {
        let language = try #require(
            SemanticCodeLanguageIdentifier("swift")
        )
        let blocks: [SemanticBlock] = [
            .code(.plain(PlainSemanticCodeBlock(runs: [
                LayoutFixture.direct("let value = 1")
            ]))),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: [LayoutFixture.direct("func value() {}")],
                language: language
            ))),
            .code(.plain(PlainSemanticCodeBlock(runs: []))),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: [],
                language: language
            )))
        ]
        for block in blocks
        {
            for width in [140.0, 720]
            {
                let result = try product(block, width: width)
                #expect(result.measurement.kind == .code)
                #expect(!result.measurement.contentFonts.isEmpty)
                #expect(result.measurement.extents.allSatisfy
                {
                    $0.content == .line(.code)
                })
                expectParity(result.measurement, result.snapshot)
            }
        }
    }

    @MainActor
    @Test("demanding Unicode preserves ordered resolved content fonts")
    func unicodeFonts() throws
    {
        let text = "cafe\u{301} कि ✈️ 👩🏽‍💻"
            + " 🇦🇲 0123456789"
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct(text),
            LayoutFixture.direct(" strong", traits: [.strong]),
            LayoutFixture.direct(" emphasis", traits: [.emphasis])
        ]))
        let result = try product(block, width: 180)
        #expect(!result.measurement.contentFonts.isEmpty)
        #expect(Set(result.measurement.contentFonts).count
            == result.measurement.contentFonts.count)
        #expect(result.measurement.extents.count > 1)
        expectParity(result.measurement, result.snapshot)
    }
}
