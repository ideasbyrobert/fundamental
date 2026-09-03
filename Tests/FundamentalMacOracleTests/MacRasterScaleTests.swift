import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacRasterExecutorTests
{
    @Test("native fill geometry follows exact backing scale")
    func fillGeometryFollowsBackingScale() throws
    {
        let one = try fillWitness(scale: 1)
        let two = try fillWitness(scale: 2)
        #expect(one.width * 2 == two.width)
        #expect(one.height * 2 == two.height)
        #expect(one.area * 4 == two.area)
    }

    func fillWitness(
        scale: Double
    ) throws -> PresentationPixelBounds
    {
        let source = try MacOracleTestSurface.snapshot(
            backingScale: scale
        )
        let origin = try #require(PresentationPoint(x: 24, y: 24))
        let size = try #require(PresentationSize(width: 40, height: 40))
        let bounds = try #require(PresentationRectangle(
            origin: origin,
            size: size
        ))
        let pixels = try #require(PresentationPixelBounds(
            logicalBounds: bounds,
            backingScale: scale
        ))
        let fill = PresentationFill(
            residentID: source.presentedDocument.residents.first.residentID,
            role: .tableBackground,
            logicalBounds: bounds,
            pixelBounds: pixels,
            color: source.presentedDocument.plane.palette.text,
            sourceSlices: []
        )
        let empty = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: []
        )
        let isolated = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: [.fill(fill)]
        )
        let emptySurface = try draw(empty)
        let fillSurface = try draw(isolated)
        let changed = fillSurface.changedPixels(
            from: emptySurface,
            in: pixels
        )
        #expect(changed.count == pixels.area)
        return pixels
    }
}
