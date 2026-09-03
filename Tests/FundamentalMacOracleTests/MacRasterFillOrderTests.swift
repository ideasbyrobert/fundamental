import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacRasterExecutorTests
{
    @Test("overlapping native fills retain stored global order")
    func overlappingFillsRetainOrder() throws
    {
        let source = try MacOracleTestSurface.snapshot()
        let document = source.presentedDocument
        let witness = try MacRasterFillFixture.overlapping(in: source)
        let pixels = witness.pixels
        let first = witness.first
        let second = witness.second
        let empty = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: []
        )
        let firstOnly = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: [.fill(first)]
        )
        let secondOnly = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: [.fill(second)]
        )
        let forward = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: [.fill(first), .fill(second)]
        )
        let reverse = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: [.fill(second), .fill(first)]
        )
        let emptySurface = try draw(empty)
        let firstSurface = try draw(firstOnly)
        let secondSurface = try draw(secondOnly)
        let forwardSurface = try draw(forward)
        let reverseSurface = try draw(reverse)
        let firstPixels = firstSurface.changedPixels(
            from: emptySurface,
            in: pixels
        )
        let allFirstPixels = firstSurface.changedPixels(
            from: emptySurface,
            in: document.plane.pixelBounds
        )
        let secondPixels = secondSurface.changedPixels(
            from: emptySurface,
            in: pixels
        )
        #expect(allFirstPixels.count == pixels.area)
        #expect(!firstPixels.isEmpty)
        #expect(!secondPixels.isEmpty)
        #expect(firstPixels.contains
        {
            firstSurface.pixel(at: $0) != secondSurface.pixel(at: $0)
        })
        #expect(forwardSurface.changedPixels(
            from: secondSurface,
            in: pixels
        ).isEmpty)
        #expect(reverseSurface.changedPixels(
            from: firstSurface,
            in: pixels
        ).isEmpty)
    }

}
