import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalRaster

extension RasterTextTests
{
    @MainActor
    @Test("every shaped run fact crosses the raster boundary exactly")
    func exactRunTransfer() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            RasterFixture.run("A😀office")
        ]))
        let layout = try RasterFixture.layout([block], width: 500)
        let raster = try RasterFixture.snapshot(
            RasterFixture.viewport(layout)
        )
        guard case let .lines(fragment) = layout.firstFragment
        else
        {
            Issue.record("Expected line layout")
            return
        }
        let batches: [RasterGlyphBatch] = raster.marks.compactMap
        {
            guard case let .glyphs(batch) = $0 else { return nil }
            return batch
        }
        #expect(batches.count == fragment.line.glyphRuns.count)
        for (batch, run) in zip(batches, fragment.line.glyphRuns)
        {
            #expect(batch.paintOrder == run.paintOrder)
            #expect(batch.font == RasterFixture.expectedFont(run.font))
            #expect(batch.textMatrix
                == RasterFixture.expectedTransform(run.textMatrix))
            #expect(batch.baselineOffset == run.style.baselineOffset)
            #expect(batch.sourceSlices
                == RasterFixture.expectedSlices(run.sourceSlices))
            let sourceGlyphs = run.glyphs
            #expect(batch.glyphs.map(\.identifier)
                == sourceGlyphs.map(\.identifier))
            #expect(batch.glyphs.map(\.advance)
                == sourceGlyphs.map
                {
                    RasterVector(dx: $0.advance.dx, dy: $0.advance.dy)
                })
            let positions = try sourceGlyphs.map
            {
                try #require(RasterPoint(
                    x: $0.position.x,
                    y: $0.position.y
                ))
            }
            #expect(batch.glyphs.map(\.position) == positions)
            #expect(batch.glyphs.map(\.sourceSlices)
                == sourceGlyphs.map
                {
                    RasterFixture.expectedSlices($0.sourceSlices)
                })
        }
    }
}
