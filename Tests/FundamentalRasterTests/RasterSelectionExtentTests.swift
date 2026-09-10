import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalRaster

@MainActor
@Suite("Raster selection extents")
struct RasterSelectionExtentTests
{
    @Test("selection edges outside the resident refuse in both raster paths")
    func outsideResident() throws
    {
        let layout = try RasterFixture.layout([
            .paragraph(SemanticParagraph(runs: [RasterFixture.run("\n")]))
        ], width: 300)
        let viewport = try RasterFixture.viewport(layout)
        let raster = try RasterFixture.snapshot(viewport)
        let fragment = try #require(RasterListFixture.lines(layout).first)
        let region = raster.interactionMap.firstRegion
        let specification = raster.lineage.specification
        for edges in [(-1.0, 300.0), (0.0, 301.0), (301.0, 0.0)]
        {
            let extent = try #require(LayoutSelectionExtent(
                leading: edges.0, trailing: edges.1
            ))
            let line = RasterListFixture.line(
                fragment.line, marker: nil, extent: extent
            )
            var budget = RasterAdmissionBudget(
                capacities: specification.capacities
            )
            #expect(!ViewportRasterizer.admits(
                line, residentID: region.residentID, role: region.role,
                frame: region.frame,
                targetBounds: specification.logicalBounds, budget: &budget
            ))
            var accumulator = RasterAccumulator(
                capacities: specification.capacities
            )
            #expect(!ViewportRasterizer.append(
                line, residentID: region.residentID, residence: .visible,
                role: region.role, frame: region.frame,
                targetBounds: specification.logicalBounds,
                specification: specification, accumulator: &accumulator
            ))
            #expect(accumulator.marks.isEmpty)
            #expect(accumulator.regions.isEmpty)
        }
    }
}
