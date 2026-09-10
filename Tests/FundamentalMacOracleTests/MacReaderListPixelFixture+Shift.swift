import Testing

@testable import FundamentalPresentation

extension MacReaderListPixelFixture
{
    static func shift(
        _ batch: PresentationGlyphBatch, in source: PresentationSnapshot,
        fraction: Double
    ) throws -> (
        PresentationSnapshot, PresentationGlyphBatch, PresentationPoint
    )
    {
        let resident = try #require(source.presentedDocument.residents.all.first
        {
            $0.residentID == batch.residentID
        })
        guard case let .list(item, .first(marker, line)) = resident.content
        else { throw MacOracleTestFailure.admission }
        let dx = marker.baseline.x.rounded(.down) + fraction - marker.baseline.x
        let dy = marker.baseline.y.rounded(.down)
            + 2 * fraction - marker.baseline.y
        let baseline = try #require(PresentationPoint(
            x: marker.baseline.x + dx, y: marker.baseline.y + dy
        ))
        let origin = try #require(PresentationPoint(
            x: marker.inkBounds.minX + dx, y: marker.inkBounds.minY + dy
        ))
        let ink = try #require(PresentationRectangle(
            origin: origin, size: marker.inkBounds.size
        ))
        let shifted = try #require(PresentationListMarker(
            source: marker.source, baseline: baseline,
            advance: marker.advance, inkBounds: ink
        ))
        let glyphs = try #require(MacRasterSnapshotFixture.shifting(
            batch, x: dx, y: dy, clip: batch.clipBounds,
            pixels: batch.pixelBounds
        ))
        let changed = PresentedResident(
            residence: resident.residence,
            storage: PresentedResidentStorage(
                residentID: resident.residentID, frame: resident.frame,
                content: .list(item, .first(shifted, line)),
                marks: [.glyphs(glyphs)]
            )
        )
        return (
            try MacRasterOriginFixture.snapshot(
                source, residents: [changed], marks: [.glyphs(glyphs)]
            ),
            glyphs, baseline
        )
    }
}
