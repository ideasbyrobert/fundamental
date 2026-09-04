import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutBlockMeasurementTests
{
    @MainActor
    @Test("regular tables retain exact counts and six fragment forms")
    func regularTable() throws
    {
        let block = SemanticBlock.table(
            try LayoutFixture.table(captioned: false)
        )
        for width in [180.0, 720]
        {
            let result = try product(block, width: width)
            let table = try #require(tableFacts(result.measurement))
            #expect(table.rowCount == 3)
            #expect(table.cellCount == 5)
            let contents = result.measurement.extents.map(\.content)
            for content in [
                .tableRegion,
                .tableColumnTrack,
                .tableRowTrack,
                .tableCell,
                .tableCellLine,
                .tableRule
            ] as [LayoutFragmentExtentContent]
            {
                #expect(contents.contains(content))
            }
            #expect(!contents.contains(.tableCaptionLine))
            expectParity(result.measurement, result.snapshot)
        }
    }

    @MainActor
    @Test("captioned tables retain the seventh grid fragment form")
    func captionedTable() throws
    {
        let blocks = [
            .table(try LayoutFixture.table(captioned: true)),
            try captionedZeroRowTable()
        ]
        for (index, block) in blocks.enumerated()
        {
            let result = try product(block, width: 360)
            let table = try #require(tableFacts(result.measurement))
            #expect(table.rowCount == [3, 0][index])
            #expect(table.cellCount == [5, 0][index])
            #expect(result.measurement.extents.map(\.content)
                .contains(.tableCaptionLine))
            #expect(!result.measurement.contentFonts.isEmpty)
            expectParity(result.measurement, result.snapshot)
        }
    }
}
