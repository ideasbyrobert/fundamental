import Testing

@testable import FundamentalDocument

@Suite("A semantic table cell extent")
struct SemanticTableCellExtentTests
{
    @Test("positive spanning dimensions are admitted")
    func positiveSpanningDimensionsAreAdmitted() throws
    {
        let dimensions = [
            (2, 1),
            (1, 2),
            (3, 4),
            (Int.max, 1)
        ]

        for (rowCount, columnCount) in dimensions
        {
            let extent = try #require(
                SemanticTableCellExtent(
                    rowCount: rowCount,
                    columnCount: columnCount
                )
            )

            #expect(extent.rowCount == rowCount)
            #expect(extent.columnCount == columnCount)
        }
    }

    @Test("one-by-one dimensions are refused")
    func oneByOneDimensionsAreRefused()
    {
        #expect(
            SemanticTableCellExtent(
                rowCount: 1,
                columnCount: 1
            ) == nil
        )
    }

    @Test("nonpositive dimensions are refused")
    func nonpositiveDimensionsAreRefused()
    {
        for dimensions in [(0, 1), (1, 0), (-1, 2), (2, -1)]
        {
            #expect(
                SemanticTableCellExtent(
                    rowCount: dimensions.0,
                    columnCount: dimensions.1
                ) == nil
            )
        }
    }
}
