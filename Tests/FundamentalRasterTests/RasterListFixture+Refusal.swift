import Testing

@testable import FundamentalLayout
@testable import FundamentalRaster

extension RasterListFixture
{
    static func expectRefusal(
        _ line: LayoutLine, owner: RasterResidentID,
        role: RasterInteractionRole, specification: RasterSpecificationIdentity
    ) throws
    {
        var budget = RasterAdmissionBudget(
            capacities: specification.capacities
        )
        let frame = try bounds(line.frame)
        #expect(!ViewportRasterizer.admits(
            line, residentID: owner, role: role, frame: frame,
            targetBounds: specification.logicalBounds, budget: &budget
        ))
        var accumulator = RasterAccumulator(
            capacities: specification.capacities
        )
        #expect(!ViewportRasterizer.append(
            line, residentID: owner, residence: .visible, role: role,
            frame: frame, targetBounds: specification.logicalBounds,
            specification: specification, accumulator: &accumulator
        ))
        #expect(accumulator.marks.isEmpty)
        #expect(accumulator.regions.isEmpty)
    }
}
