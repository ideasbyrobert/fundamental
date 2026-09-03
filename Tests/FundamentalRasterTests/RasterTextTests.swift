import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalRaster

@Suite("Raster text evidence")
struct RasterTextTests
{
    @MainActor
    @Test("shaped glyph font order geometry and source remain exact")
    func exactGlyphs() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            RasterFixture.run("A"),
            RasterFixture.run(
                "😀office",
                traits: [.underline, .strikethrough]
            )
        ]))
        let layout = try RasterFixture.layout([block], width: 500)
        let viewport = try RasterFixture.viewport(layout)
        let raster = try RasterFixture.snapshot(viewport)
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
        #expect(batches.map(\.paintOrder)
            == fragment.line.glyphRuns.map(\.paintOrder))
        #expect(batches.flatMap(\.glyphs).map(\.identifier)
            == fragment.line.glyphRuns.flatMap(\.glyphs)
                .map(\.identifier))
        #expect(batches.flatMap(\.glyphs).map(\.sourceSlices)
            .flatMap { $0 }.map(\.text)
            == fragment.line.glyphRuns.flatMap(\.glyphs)
                .flatMap(\.sourceSlices).map(\.text))
        #expect(batches.map(\.font.postScriptName)
            == fragment.line.glyphRuns.map(\.font.postScriptName))
        #expect(batches.allSatisfy
        {
            batch in
            let resident = viewport.residents.all.first
            {
                $0.fragment.anchor.fragmentOrdinal
                    == batch.residentID.fragmentOrdinal
            }
            guard let resident,
                  let frame = try? RasterFixture.rectangle(
                      x: resident.fragment.frame.minX,
                      y: resident.fragment.frame.minY,
                      width: resident.fragment.frame.size.width,
                      height: resident.fragment.frame.size.height
                  )
            else
            {
                return false
            }
            return batch.clipBounds == frame.intersection(
                raster.lineage.specification.logicalBounds
            )
        })
    }

}
