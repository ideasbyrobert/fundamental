import Testing

@testable import FundamentalDocument

@Suite("A regular semantic table")
struct RegularSemanticTableTests
{
    @Test("initialization preserves immutable content")
    func initializationPreservesImmutableContent()
    {
        let content = SemanticTableContent(
            headerRows: [HeaderSemanticTableRow(cells: [])],
            bodyRows: [],
            columnAlignments: [.leading]
        )
        let table = RegularSemanticTable(content: content)

        #expect(table.content == content)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged()
    {
        let original = RegularSemanticTable(
            content: SemanticTableContent(
                headerRows: [],
                bodyRows: [],
                columnAlignments: []
            )
        )
        let changed = RegularSemanticTable(
            content: SemanticTableContent(
                headerRows: [],
                bodyRows: [BodySemanticTableRow(cells: [])],
                columnAlignments: [.trailing]
            )
        )

        #expect(original != changed)
        #expect(original.content.bodyRows.isEmpty)
        #expect(original.content.columnAlignments.isEmpty)
    }
}
