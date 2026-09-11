import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

extension MacReaderListTests
{
    @Test("generated markers match independent native glyph drawing",
          arguments: [
            (SemanticListKind.bulleted, 1), (.numbered, 1),
            (.numbered, 9), (.numbered, 10), (.numbered, 99), (.numbered, 100)
          ])
    func markerPixels(sample: (SemanticListKind, Int)) throws
    {
        for scale in [1.0, 2]
        {
            let snapshot = try MacReaderListPixelFixture.snapshot(
                kind: sample.0, count: sample.1, scale: scale
            )
            let batch = try #require(snapshot.presentedDocument.marks
                .compactMap
            {
                mark -> PresentationGlyphBatch? in
                guard case let .glyphs(batch) = mark,
                      case .listMarker = batch.source,
                      batch.residentID.blockOrdinal == sample.1 - 1
                else { return nil }
                return batch
            }.first)
            for fraction in [0.0, 0.25]
            {
                let (shifted, glyphs, baseline) =
                    try MacReaderListPixelFixture.shift(
                        batch, in: snapshot, fraction: fraction
                    )
                #expect(baseline.x - baseline.x.rounded(.down) == fraction)
                #expect(baseline.y - baseline.y.rounded(.down) == 2 * fraction)
                let empty = MacRasterSnapshotFixture.replacingMarks(
                    in: shifted, with: []
                )
                let native = try #require(MacBitmapSurface(empty))
                #expect(native.draw(empty))
                native.drawNativeLine(
                    try MacReaderListPixelFixture.nativeLine(glyphs),
                    batch: glyphs, origin: baseline
                )
                let actual = try #require(MacBitmapSurface(shifted))
                #expect(actual.draw(shifted))
                let changed = actual.changedPixels(
                    from: native,
                    in: shifted.presentedDocument.plane.pixelBounds
                )
                #expect(changed.isEmpty)
                #expect(glyphs.sourceSlices.isEmpty)
                let name = "list-\(sample.0)-\(sample.1)-\(scale)-\(fraction)"
                try MacRasterOriginFixture.capture(
                    native, name: "native-\(name)"
                )
                try MacRasterOriginFixture.capture(
                    actual, name: "owned-\(name)"
                )
            }
        }
    }
}
