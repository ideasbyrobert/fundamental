import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func expectBatch(
        _ source: RasterGlyphBatch,
        equals result: PresentationGlyphBatch
    )
    {
        #expect(source.paintOrder == result.paintOrder)
        #expect(source.residentID.blockID == result.residentID.blockID)
        #expect(source.residentID.blockOrdinal
            == result.residentID.blockOrdinal)
        #expect(source.residentID.fragmentOrdinal
            == result.residentID.fragmentOrdinal)
        #expect(rectangleSignature(source.logicalBounds)
            == rectangleSignature(result.logicalBounds))
        #expect(rectangleSignature(source.clipBounds)
            == rectangleSignature(result.clipBounds))
        #expect(pixelSignature(source.pixelBounds)
            == pixelSignature(result.pixelBounds))
        expectFont(source.font, equals: result.font)
        #expect(transformSignature(source.textMatrix)
            == transformSignature(result.textMatrix))
        #expect(source.baselineOffset == result.baselineOffset)
        #expect(source.color.components == result.color.components)
        #expect(source.color.alpha == result.color.alpha)
        #expect(source.color.colorSpace.name
            == result.color.colorSpace.name)
        #expect(source.color.colorSpace.profile
            == result.color.colorSpace.profile)
        expectSlices(source.sourceSlices, equals: result.sourceSlices)
        #expect(source.glyphs.count == result.glyphs.count)
        for pair in zip(source.glyphs, result.glyphs)
        {
            #expect(pair.0.identifier == pair.1.identifier)
            #expect(pair.0.position.x == pair.1.position.x)
            #expect(pair.0.position.y == pair.1.position.y)
            #expect(pair.0.advance.dx == pair.1.advance.dx)
            #expect(pair.0.advance.dy == pair.1.advance.dy)
            expectSlices(pair.0.sourceSlices, equals: pair.1.sourceSlices)
        }
    }
}
