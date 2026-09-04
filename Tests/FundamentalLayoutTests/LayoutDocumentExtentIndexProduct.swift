import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

extension LayoutDocumentExtentIndexTests
{
    @MainActor
    func product(
        _ blocks: [SemanticBlock],
        width: Double,
        capacity: LayoutExtentIndexCapacity? = nil
    ) throws -> (
        index: LayoutDocumentExtentIndex,
        snapshot: LayoutSnapshot,
        projection: ProjectionSnapshot,
        request: LayoutRequest
    )
    {
        let projection = try LayoutFixture.projection(blocks)
        let request = try LayoutFixture.request(width: width)
        let layout = NativeTextKit2Layout()
        let selectedCapacity = try capacity ?? self.capacity()
        return (
            try layout.extentIndex(
                projection,
                request: request,
                capacity: selectedCapacity
            ),
            try layout.layout(projection, request: request),
            projection,
            request
        )
    }

    @MainActor
    func measurements(
        _ projection: ProjectionSnapshot,
        request: LayoutRequest
    ) throws -> [LayoutBlockMeasurement]
    {
        let layout = NativeTextKit2Layout()
        return try projection.blocks.map
        {
            try layout.measure($0, parameters: request.parameters)
        }
    }
}
