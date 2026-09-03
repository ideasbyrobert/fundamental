import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

extension MacRasterExecutorTests
{
    @Test("native glyph pixels follow carried integer positions")
    func glyphPixelsFollowPositions() throws
    {
        let source = try MacOracleTestSurface.snapshot()
        let plane = source.presentedDocument.plane
        let batch = try #require(
            MacRasterSnapshotFixture.firstTextBatch(in: source)
        )
        let original = try #require(MacRasterSnapshotFixture.glyphBatch(
            batch,
            glyphs: batch.glyphs,
            clip: plane.logicalBounds,
            pixels: plane.pixelBounds
        ))
        let deviceX = 4
        let deviceY = 6
        let shifted = try #require(MacRasterSnapshotFixture.shifting(
            original,
            x: Double(deviceX) / plane.backingScale,
            y: Double(deviceY) / plane.backingScale,
            clip: plane.logicalBounds,
            pixels: plane.pixelBounds
        ))
        let empty = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: []
        )
        let first = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: [.glyphs(original)]
        )
        let second = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: [.glyphs(shifted)]
        )
        let emptySurface = try draw(empty)
        let firstSurface = try draw(first)
        let secondSurface = try draw(second)
        let originalPixels = firstSurface.changedPixels(
            from: emptySurface,
            in: plane.pixelBounds
        )
        let shiftedPixels = secondSurface.changedPixels(
            from: emptySurface,
            in: plane.pixelBounds
        )
        let expected = Set(originalPixels.map
        {
            $0 + deviceY * firstSurface.width + deviceX
        })
        #expect(!originalPixels.isEmpty)
        #expect(shiftedPixels == expected)
    }
}
