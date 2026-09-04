import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

extension LayoutDocumentExtentIndexTests
{
    @MainActor
    @Test("incomplete counterfeit and nonfinite indexes refuse atomically")
    func constructionRefusal() throws
    {
        let base = try product(try mixedBlocks(), width: 360)
        let values = try measurements(
            base.projection,
            request: base.request
        )
        let admittedCapacity = try capacity()
        #expect(admit(base, values: Array(values.dropLast()),
                      capacity: admittedCapacity) == nil)
        #expect(admit(base, values: values.reversed(),
                      capacity: admittedCapacity) == nil)
        let otherRequest = try LayoutFixture.request(width: 400)
        var mixedParameters = values
        mixedParameters[0] = try NativeTextKit2Layout().measure(
            base.projection.blocks[0],
            parameters: otherRequest.parameters
        )
        #expect(admit(base, values: mixedParameters,
                      capacity: admittedCapacity) == nil)
        try expectDuplicateRefusal(capacity: admittedCapacity)
        try expectContentRefusal(capacity: admittedCapacity)
        try expectCaptionRefusal(capacity: admittedCapacity)
        try expectPlacementOverflow(capacity: admittedCapacity)
        #expect(base.projection.blocks.count == 4)
        #expect(values.count == 4)
    }

    func admit(
        _ base: (
            index: LayoutDocumentExtentIndex,
            snapshot: LayoutSnapshot,
            projection: ProjectionSnapshot,
            request: LayoutRequest
        ),
        values: some Sequence<LayoutBlockMeasurement>,
        capacity: LayoutExtentIndexCapacity
    ) -> LayoutDocumentExtentIndex?
    {
        LayoutDocumentExtentIndex(
            projection: base.projection,
            request: base.request,
            capacity: capacity,
            measurements: Array(values)
        )
    }
}
