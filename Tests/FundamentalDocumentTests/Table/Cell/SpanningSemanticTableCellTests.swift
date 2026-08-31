import Testing

@testable import FundamentalDocument

@Suite("A spanning semantic table cell")
struct SpanningSemanticTableCellTests
{
    @Test("initialization preserves immutable facts")
    func initializationPreservesImmutableFacts() throws
    {
        let extent = try #require(
            SemanticTableCellExtent(
                rowCount: 2,
                columnCount: 3
            )
        )
        let runs = [SemanticRun(text: "Wide")]
        let cell = SpanningSemanticTableCell(
            runs: runs,
            alignment: .leading,
            extent: extent
        )

        #expect(cell.runs == runs)
        #expect(cell.alignment == .leading)
        #expect(cell.extent == extent)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let originalExtent = try #require(
            SemanticTableCellExtent(
                rowCount: 2,
                columnCount: 1
            )
        )
        let changedExtent = try #require(
            SemanticTableCellExtent(
                rowCount: 3,
                columnCount: 4
            )
        )
        let original = SpanningSemanticTableCell(
            runs: [SemanticRun(text: "Body")],
            extent: originalExtent
        )
        let changed = SpanningSemanticTableCell(
            runs: [SemanticRun(text: "Changed")],
            alignment: .center,
            extent: changedExtent
        )

        #expect(original != changed)
        #expect(original.runs == [SemanticRun(text: "Body")])
        #expect(original.extent == originalExtent)
    }
}
