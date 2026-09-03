import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

extension MacRasterExecutorTests
{
    @Test("native glyph clipping removes only excluded pixels")
    func glyphClippingRemovesExcludedPixels() throws
    {
        let source = try MacOracleTestSurface.snapshot()
        let plane = source.presentedDocument.plane
        let batch = try #require(
            MacRasterSnapshotFixture.firstTextBatch(in: source)
        )
        let full = try #require(MacRasterSnapshotFixture.glyphBatch(
            batch,
            glyphs: batch.glyphs,
            clip: plane.logicalBounds,
            pixels: plane.pixelBounds
        ))
        let empty = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: []
        )
        let isolated = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: [.glyphs(full)]
        )
        let emptySurface = try draw(empty)
        let fullSurface = try draw(isolated)
        let fullPixels = fullSurface.changedPixels(
            from: emptySurface,
            in: plane.pixelBounds
        )
        let columns = Set(fullPixels.map
        {
            $0 % fullSurface.width
        }).sorted()
        let boundary = try #require(columns.dropFirst().dropLast().first)
        let clipMaximumX = plane.pixelBounds.minimumX + boundary
        let clipWidth = Double(clipMaximumX)
            / plane.backingScale - plane.logicalBounds.minX
        let clipOrigin = try #require(PresentationPoint(
            x: plane.logicalBounds.minX,
            y: plane.logicalBounds.minY
        ))
        let clipSize = try #require(PresentationSize(
            width: clipWidth,
            height: plane.logicalBounds.size.height
        ))
        let clip = try #require(PresentationRectangle(
            origin: clipOrigin,
            size: clipSize
        ))
        let clipPixels = try #require(PresentationPixelBounds(
            logicalBounds: clip,
            backingScale: plane.backingScale
        ))
        let clippedBatch = try #require(
            MacRasterSnapshotFixture.glyphBatch(
                full,
                glyphs: full.glyphs,
                clip: clip,
                pixels: clipPixels
            )
        )
        let clipped = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: [.glyphs(clippedBatch)]
        )
        let clippedSurface = try draw(clipped)
        let clippedPixels = clippedSurface.changedPixels(
            from: emptySurface,
            in: plane.pixelBounds
        )
        let expected = Set(fullPixels.filter
        {
            $0 % fullSurface.width < boundary
        })
        #expect(!expected.isEmpty)
        #expect(expected.count < fullPixels.count)
        #expect(clippedPixels == expected)
    }
}
