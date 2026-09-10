import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacRasterOriginTests
{
    func compareNativePixels(
        _ batch: PresentationGlyphBatch, in snapshot: PresentationSnapshot,
        label: String
    ) throws
    {
        let native = try MacRasterOriginFixture.nativeLine(batch)
        let line = try MacRasterOriginFixture.line(for: batch, in: snapshot)
        let empty = MacRasterSnapshotFixture.replacingMarks(
            in: snapshot, with: []
        )
        let expected = try #require(MacBitmapSurface(empty))
        #expect(expected.draw(empty))
        expected.drawNativeLine(native, batch: batch, origin: line.baseline)
        let actual = try #require(MacBitmapSurface(snapshot))
        #expect(actual.draw(snapshot))
        let count = actual.changedPixels(
            from: expected, in: batch.pixelBounds
        ).count
        #expect(count == 0, "Emoji \(label)")
        try MacRasterOriginFixture.capture(expected, name: "native-\(label)")
        try MacRasterOriginFixture.capture(actual, name: "owned-\(label)")
    }
}
