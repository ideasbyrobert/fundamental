import Testing

@testable import FundamentalLayout
@testable import FundamentalRaster

extension RasterListFixture
{
    static func expect(
        _ batch: RasterGlyphBatch, run: LayoutGlyphRun,
        line: LayoutLine, frame: LayoutRectangle, raster: RasterSnapshot
    ) throws
    {
        let specification = raster.lineage.specification
        let logical = try bounds(line.frame)
        let clip = try #require(bounds(frame).intersection(
            specification.logicalBounds
        ))
        #expect(batch.paintOrder == run.paintOrder)
        #expect(batch.font == RasterFixture.expectedFont(run.font))
        #expect(batch.textMatrix
            == RasterFixture.expectedTransform(run.textMatrix))
        #expect(batch.baselineOffset == run.style.baselineOffset)
        #expect(batch.logicalBounds == logical)
        #expect(batch.clipBounds == clip)
        #expect(batch.pixelBounds == RasterPixelBounds(
            logicalBounds: clip, backingScale: specification.backingScale
        ))
        #expect(batch.color == specification.palette.text)
        #expect(batch.sourceSlices
            == RasterFixture.expectedSlices(run.sourceSlices))
        #expect(batch.glyphs.count == run.glyphs.count)
        for (glyph, native) in zip(batch.glyphs, run.glyphs)
        {
            #expect(glyph.identifier == native.identifier)
            #expect(glyph.position == (try point(native.position)))
            #expect(glyph.advance == RasterVector(
                dx: native.advance.dx, dy: native.advance.dy
            ))
            #expect(glyph.sourceSlices
                == RasterFixture.expectedSlices(native.sourceSlices))
        }
    }
}
