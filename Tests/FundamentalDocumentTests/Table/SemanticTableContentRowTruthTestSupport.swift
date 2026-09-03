import Testing

@testable import FundamentalDocument

extension SemanticTableContentTests
{
    static func spanningCell(
        rows: Int,
        columns: Int
    ) throws -> SemanticTableCell
    {
        let extent = try #require(SemanticTableCellExtent(
            rowCount: rows,
            columnCount: columns
        ))
        return .spanning(SpanningSemanticTableCell(
            runs: [],
            extent: extent
        ))
    }
}
