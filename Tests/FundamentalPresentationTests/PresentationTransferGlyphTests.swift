import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    @MainActor
    @Test("every renderer glyph fact transfers without reconstruction")
    func glyphEvidence() throws
    {
        let link = try #require(SemanticLinkDestination("https://glyph.test"))
        let language = try #require(SemanticLanguageIdentifier("en"))
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            .scoped(SemanticScopedRun(
                text: "office e\u{301} 👩🏽‍💻",
                scopes: .linkAndLanguage(
                    link: link,
                    language: language
                )
            ))
        ]))
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([block], width: 500)
            )
        )
        let document = try PresentationFixture.snapshot(raster)
            .presentedDocument
        let source: [RasterGlyphBatch] = raster.marks.compactMap
        {
            guard case let .glyphs(batch) = $0
            else
            {
                return nil
            }
            return batch
        }
        let result: [PresentationGlyphBatch] = document.marks.compactMap
        {
            guard case let .glyphs(batch) = $0
            else
            {
                return nil
            }
            return batch
        }
        #expect(source.count == result.count)
        for pair in zip(source, result)
        {
            expectBatch(pair.0, equals: pair.1)
        }
    }
}
