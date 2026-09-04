import Testing

@testable import FundamentalLayout
@testable import FundamentalProjection

extension ViewportWindowFixture
{
    @MainActor
    static func layouts(
        projection: ProjectionSnapshot,
        width: Double,
        indexCapacity: LayoutExtentIndexCapacity? = nil
    ) throws -> (
        eager: LayoutSnapshot,
        indexed: LayoutIndexedProjection,
        request: LayoutRequest
    )
    {
        let request = try #require(LayoutRequest(
            generation: 11,
            width: width,
            blockSpacing: 18,
            rowSpacing: 6,
            columnSpacing: 10,
            cellPadding: 8
        ))
        let layout = NativeTextKit2Layout()
        let capacity = try indexCapacity ?? Self.indexCapacity()
        return (
            try layout.layout(projection, request: request),
            try layout.indexedProjection(
                projection,
                request: request,
                capacity: capacity
            ),
            request
        )
    }

    static func bounds(
        width: Double,
        originY: Double,
        height: Double
    ) throws -> LayoutRectangle
    {
        let origin = try #require(LayoutPoint(x: 0, y: originY))
        let size = try #require(LayoutSize(width: width, height: height))
        return try #require(LayoutRectangle(origin: origin, size: size))
    }
}
