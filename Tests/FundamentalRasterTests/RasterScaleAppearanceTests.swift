import Testing

@testable import FundamentalDocument
@testable import FundamentalRaster
@testable import FundamentalViewport

@Suite("Raster scale and appearance lineage")
struct RasterScaleAppearanceTests
{
    @MainActor
    @Test("scale changes pixel bounds but not logical marks")
    func scale() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            RasterFixture.run("Scale")
        ]))
        let viewport = try RasterFixture.viewport(
            RasterFixture.layout([block])
        )
        let one = try snapshot(viewport, scale: 1)
        let fractional = try snapshot(viewport, scale: 1.5)
        let two = try snapshot(viewport, scale: 2)
        #expect(one.lineage.specification.pixelBounds
            != two.lineage.specification.pixelBounds)
        #expect(logicalMarks(one) == logicalMarks(two))
        #expect(logicalMarks(one) == logicalMarks(fractional))
    }

    @MainActor
    @Test("appearance changes lineage without changing resident facts")
    func appearance() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            RasterFixture.run("Appearance")
        ]))
        let viewport = try RasterFixture.viewport(
            RasterFixture.layout([block])
        )
        let light = try snapshot(viewport, luminosity: .light)
        let dark = try snapshot(
            viewport,
            luminosity: .dark,
            contrast: .increased
        )
        #expect(light.lineage.specification.appearance
            != dark.lineage.specification.appearance)
        #expect(logicalMarks(light) == logicalMarks(dark))
        #expect(light.interactionMap == dark.interactionMap)
    }

    private func snapshot(
        _ viewport: ViewportSnapshot,
        scale: Double = 2,
        luminosity: RasterLuminosity = .light,
        contrast: RasterContrast = .standard
    ) throws -> RasterSnapshot
    {
        let specification = try RasterFixture.specification(
            viewport,
            scale: scale,
            luminosity: luminosity,
            contrast: contrast
        )
        return try #require(ViewportRasterizer().rasterize(
            viewport,
            request: RasterRequest(
                expectedViewportLineage: viewport.lineage,
                generation: 44,
                specification: specification
            )
        ))
    }

    private func logicalMarks(_ snapshot: RasterSnapshot) -> [String]
    {
        snapshot.marks.map
        {
            switch $0
            {
            case let .glyphs(batch):
                "g:\(batch.logicalBounds):\(batch.clipBounds):"
                    + "\(batch.glyphs)"
            case let .fill(fill):
                "f:\(fill.role):\(fill.logicalBounds)"
            }
        }
    }
}
