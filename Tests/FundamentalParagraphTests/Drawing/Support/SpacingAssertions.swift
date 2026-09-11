@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
enum SpacingAssertions
{
    static func geometry(_ line: SpacedNativeLine) throws
    {
        let plan = line.plan
        let gaps = plan.metrics.gaps.map(\.index)
        let delta = plan.spacing.adjustment
        var covered: Set<Int> = []
        for run in line.runs
        {
            for glyph in run.glyphs
            {
                let old = glyph.original
                let before = gaps.filter { $0 < old.stringIndex }.count
                #expect(abs(glyph.position.x - old.position.x
                    - Double(before) * delta) < 0.000001)
                #expect(glyph.position.y == old.position.y)
                let gap = gaps.contains(old.stringIndex)
                let expected = old.advance.width + (gap ? delta : 0)
                #expect(abs(glyph.advance.width - expected) < 0.000001)
                #expect(glyph.advance.height == old.advance.height)
                if gap
                {
                    covered.insert(old.stringIndex)
                }
                try AutomaticAssertions.sources(
                    plan.shaped.display, range: old.displayRange,
                    values: old.sources
                )
            }
            for decoration in run.decorations
            {
                try AutomaticAssertions.sources(
                    plan.shaped.display, range: run.original.range,
                    values: decoration.sources
                )
            }
        }
        #expect(covered == Set(gaps))
        #expect(abs(line.advance - plan.spacing.advance) < 0.000001)
        _ = try ExplicitFixture.reconstructed(plan.shaped.display.body.slice)
    }

    static func unclipped(_ raster: SpacingRaster, empty: Bool = false)
    {
        if empty
        {
            #expect(raster.coveredPixels == 0)
            #expect(raster.pixelBounds.isNull)
        }
        else
        {
            #expect(raster.coveredPixels > 0)
            let bounds = raster.pixelBounds
            #expect(bounds.minX > 1 && bounds.minY > 1)
            #expect(bounds.maxX < Double(raster.width) - 1)
            #expect(bounds.maxY < Double(raster.height) - 1)
        }
    }
}
