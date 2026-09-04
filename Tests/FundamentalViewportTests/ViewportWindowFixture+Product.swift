import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection
@testable import FundamentalViewport

extension ViewportWindowFixture
{
    @MainActor
    static func product(
        projection: ProjectionSnapshot,
        width: Double,
        originY: Double,
        height: Double,
        overscan: Double,
        limit: Int,
        materializationCapacity: LayoutMaterializationCapacity? = nil
    ) throws -> ViewportWindowTestProduct
    {
        let layoutRequest = try #require(LayoutRequest(
            generation: 11,
            width: width,
            blockSpacing: 18,
            rowSpacing: 6,
            columnSpacing: 10,
            cellPadding: 8
        ))
        let layout = NativeTextKit2Layout()
        let eager = try layout.layout(projection, request: layoutRequest)
        let indexed = try layout.indexedProjection(
            projection,
            request: layoutRequest,
            capacity: try indexCapacity()
        )
        let bounds = try Self.bounds(
            width: width,
            originY: originY,
            height: height
        )
        let request = try #require(ViewportRequest(
            expectedLayoutLineage: indexed.lineage,
            generation: 13,
            visibleBounds: bounds,
            precedingOverscanExtent: overscan,
            followingOverscanExtent: overscan,
            maximumResidentCount: limit
        ))
        let expected = try #require(ViewportSnapshot(
            eager,
            request: request
        ))
        let capacity = try materializationCapacity
            ?? Self.materializationCapacity()
        let diagnostics = try #require(
            try ViewportSnapshot.windowAdmissionDiagnostics(
                indexed,
                request: request,
                capacity: capacity
            )
        )
        return ViewportWindowTestProduct(
            projection: projection,
            eager: eager,
            indexed: indexed,
            request: request,
            expected: expected,
            diagnostics: diagnostics
        )
    }

    @MainActor
    static func product(
        blocks: [SemanticBlock],
        width: Double,
        originY: Double,
        height: Double,
        overscan: Double,
        limit: Int
    ) throws -> ViewportWindowTestProduct
    {
        try product(
            projection: projection(blocks),
            width: width,
            originY: originY,
            height: height,
            overscan: overscan,
            limit: limit
        )
    }
}
