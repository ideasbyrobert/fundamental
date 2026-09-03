import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalRaster

@Suite("Raster native Unicode witnesses")
struct RasterUnicodeWitnessTests
{
    @MainActor
    @Test("ligature bidi combining and emoji evidence is not reshaped")
    func exactNativeOrder() throws
    {
        let value = "office אבג e\u{301} 👨‍👩‍👧‍👦"
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            RasterFixture.run(value)
        ]))
        let layout = try RasterFixture.layout([block], width: 600)
        let viewport = try RasterFixture.viewport(layout)
        let raster = try RasterFixture.snapshot(viewport)
        guard case let .lines(fragment) = layout.firstFragment,
              case let .text(text) = raster.interactionMap
                  .firstRegion.content
        else
        {
            Issue.record("Expected one native text line")
            return
        }
        let batches: [RasterGlyphBatch] = raster.marks.compactMap
        {
            guard case let .glyphs(batch) = $0 else { return nil }
            return batch
        }
        #expect(text.text == fragment.line.text)
        #expect(text.sourceSlices.map(\.text)
            == fragment.line.sourceSlices.map(\.text))
        #expect(text.caretSites.map(\.utf16Offset)
            == fragment.line.caretStops.map(\.utf16Offset))
        #expect(batches.flatMap(\.glyphs).map(\.identifier)
            == fragment.line.glyphRuns.flatMap(\.glyphs)
                .map(\.identifier))
        #expect(batches.flatMap(\.glyphs).flatMap(\.sourceSlices)
            .map(\.range)
            == fragment.line.glyphRuns.flatMap(\.glyphs)
                .flatMap(\.sourceSlices).map(\.range))
    }
}
