import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

extension LayoutDocumentExtentIndexTests
{
    @MainActor
    func expectDuplicateRefusal(
        capacity: LayoutExtentIndexCapacity
    ) throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: []))
        let projection = try LayoutFixture.projection([block, block])
        let request = try LayoutFixture.request(width: 320)
        let duplicate = ProjectionSnapshot(
            lineage: projection.lineage,
            firstBlock: projection.firstBlock,
            remainingBlocks: [projection.firstBlock]
        )
        let first = try NativeTextKit2Layout().measure(
            projection.firstBlock,
            parameters: request.parameters
        )
        #expect(LayoutDocumentExtentIndex(
            projection: duplicate,
            request: request,
            capacity: capacity,
            measurements: [first, first]
        ) == nil)
    }

    @MainActor
    func expectCaptionRefusal(
        capacity: LayoutExtentIndexCapacity
    ) throws
    {
        let regular = try LayoutFixture.projection([
            .table(try LayoutFixture.table(captioned: false))
        ])
        let captioned = try LayoutFixture.projection([
            .table(try LayoutFixture.table(captioned: true))
        ])
        let request = try LayoutFixture.request(width: 360)
        let value = try NativeTextKit2Layout().measure(
            captioned.firstBlock,
            parameters: request.parameters
        )
        #expect(LayoutDocumentExtentIndex(
            projection: regular,
            request: request,
            capacity: capacity,
            measurements: [value]
        ) == nil)
    }

    @MainActor
    func expectPlacementOverflow(
        capacity: LayoutExtentIndexCapacity
    ) throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: []))
        let projection = try LayoutFixture.projection([block, block, block])
        let request = try #require(LayoutRequest(
            generation: 11,
            width: 320,
            blockSpacing: Double.greatestFiniteMagnitude,
            rowSpacing: 4,
            columnSpacing: 6,
            cellPadding: 5
        ))
        #expect(throws: LayoutFailure.unrepresentableDocumentExtentIndex)
        {
            try NativeTextKit2Layout().extentIndex(
                projection,
                request: request,
                capacity: capacity
            )
        }
    }
}
