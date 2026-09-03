import Testing

@testable import FundamentalDocument

@Suite("A regular semantic table")
struct RegularSemanticTableTests
{
    @Test("initialization preserves immutable content")
    func initializationPreservesImmutableContent() throws
    {
        let content = try #require(SemanticTableContent(
            headerRows: [HeaderSemanticTableRow(cells: [])],
            bodyRows: [],
            columnAlignments: [.leading]
        ))
        let table = RegularSemanticTable(content: content)

        #expect(table.content == content)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let original = RegularSemanticTable(
            content: try #require(SemanticTableContent(
                headerRows: [],
                bodyRows: [],
                columnAlignments: []
            ))
        )
        let changed = RegularSemanticTable(
            content: try #require(SemanticTableContent(
                headerRows: [],
                bodyRows: [BodySemanticTableRow(cells: [])],
                columnAlignments: [.trailing]
            ))
        )

        #expect(original != changed)
        #expect(original.content.bodyRows.isEmpty)
        #expect(original.content.columnAlignments.isEmpty)
    }
}
