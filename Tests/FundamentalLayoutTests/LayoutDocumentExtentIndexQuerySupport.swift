import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

extension LayoutDocumentExtentIndexTests
{
    @MainActor
    func longProduct() throws -> (
        index: LayoutDocumentExtentIndex,
        snapshot: LayoutSnapshot,
        projection: ProjectionSnapshot,
        request: LayoutRequest
    )
    {
        let text = String(
            repeating: "Finite lightweight extent query. ",
            count: 500
        )
        return try product([
            .paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct(text)
            ]))
        ], width: 120)
    }

    func fullBounds(
        _ index: LayoutDocumentExtentIndex
    ) throws -> LayoutRectangle
    {
        let origin = try #require(LayoutPoint(x: 0, y: 0))
        return try #require(LayoutRectangle(
            origin: origin,
            size: index.size
        ))
    }

    func interiorBounds(
        _ index: LayoutDocumentExtentIndex,
        extentOrdinal: Int,
        height: Double
    ) throws -> LayoutRectangle
    {
        let extent = index.extents[extentOrdinal]
        let origin = try #require(LayoutPoint(
            x: 0,
            y: extent.frame.minY + extent.frame.size.height / 2
        ))
        let size = try #require(LayoutSize(
            width: index.size.width,
            height: height
        ))
        return try #require(LayoutRectangle(
            origin: origin,
            size: size
        ))
    }
}
