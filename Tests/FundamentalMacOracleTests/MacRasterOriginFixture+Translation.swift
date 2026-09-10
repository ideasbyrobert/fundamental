import Testing

@testable import FundamentalPresentation

extension MacRasterOriginFixture
{
    static func shift(
        _ batch: PresentationGlyphBatch, in source: PresentationSnapshot,
        x: Double, y: Double
    ) throws -> (PresentationSnapshot, PresentationGlyphBatch)
    {
        let original = try line(for: batch, in: source)
        let shifted = line(original, baseline: try #require(
            PresentationPoint(
                x: original.baseline.x + x, y: original.baseline.y + y
            )
        ))
        let matching = try #require(
            source.presentedDocument.residents.all.first
            {
                $0.residentID == batch.residentID
            }
        )
        let glyphs = try #require(MacRasterSnapshotFixture.shifting(
            batch, x: x, y: y, clip: batch.clipBounds,
            pixels: batch.pixelBounds
        ))
        return (try snapshot(
            source, residents: [resident(matching, content: .body(shifted))],
            marks: [.glyphs(glyphs)]
        ), glyphs)
    }
}
