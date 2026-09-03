import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    @MainActor
    @Test("line geometry source slices and every caret site transfer exactly")
    func interactionEvidence() throws
    {
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([
                    .paragraph(SemanticParagraph(runs: [
                        PresentationFixture.run("A e\u{301} 👩🏽‍💻")
                    ]))
                ], width: 500)
            )
        )
        guard case let .text(source) = raster.interactionMap
            .firstRegion.content
        else
        {
            Issue.record("Expected raster text")
            return
        }
        let snapshot = try PresentationFixture.snapshot(raster)
        let result = try #require(
            PresentationFixture.textResidents(snapshot).first?.1
        )
        #expect(source.text == result.text)
        #expect(rectangleSignature(source.lineBounds)
            == rectangleSignature(result.lineBounds))
        #expect(source.baseline.x == result.baseline.x)
        #expect(source.baseline.y == result.baseline.y)
        expectFont(source.defaultFont, equals: result.defaultFont)
        expectSlices(source.sourceSlices, equals: result.sourceSlices)
        #expect(source.caretSites.count == result.caretSites.count)
        for pair in zip(source.caretSites, result.caretSites)
        {
            #expect(pair.0.utf16Offset == pair.1.utf16Offset)
            #expect(pair.0.position.x == pair.1.position.x)
            #expect(pair.0.position.y == pair.1.position.y)
            #expect(pointSignature(pair.0.sourcePoint)
                == pointSignature(pair.1.sourcePoint))
        }
    }
}
