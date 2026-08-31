import Testing

@testable import FundamentalDocument

@Suite("A semantic table record")
struct SemanticTableRecordTests
{
    static func captionedTable() -> SemanticTable
    {
        let table = SourcedSemanticTableTests.table()
        let caption = SemanticTableCaption(
            firstRun: SemanticRun(text: "Caption"),
            remainingRuns: []
        )
        return .captioned(CaptionedSemanticTable(
            content: table.content,
            caption: caption
        ))
    }

    @Test("semantic case owns bare regular and captioned tables")
    func semanticCaseOwnsBareRegularAndCaptionedTables()
    {
        let tables = [
            SourcedSemanticTableTests.table(),
            Self.captionedTable()
        ]

        for table in tables
        {
            let record = SemanticTableRecord.semantic(table)
            #expect(record.table == table)
            guard case .semantic = record
            else
            {
                Issue.record("Expected a semantic record")
                return
            }
        }
    }

    @Test("sourced case owns regular and captioned tables with evidence")
    func sourcedCaseOwnsRegularAndCaptionedTablesWithEvidence() throws
    {
        let fact = try SemanticTableEvidenceTests.confidence(
            target: .table
        )
        let tables = [
            SourcedSemanticTableTests.table(),
            Self.captionedTable()
        ]

        for table in tables
        {
            let sourced = try SourcedSemanticTableTests.sourced(
                table: table,
                facts: [fact]
            )
            let record = SemanticTableRecord.sourced(sourced)
            #expect(record.table == table)
            guard case .sourced = record
            else
            {
                Issue.record("Expected a sourced record")
                return
            }
        }
    }

    @Test("reconstruction leaves original record unchanged")
    func reconstructionLeavesOriginalRecordUnchanged() throws
    {
        let originalTable = SourcedSemanticTableTests.table()
        let original = SemanticTableRecord.semantic(originalTable)
        let fact = try SemanticTableEvidenceTests.confidence(
            target: .table
        )
        let changedTable = Self.captionedTable()
        let changed = SemanticTableRecord.sourced(
            try SourcedSemanticTableTests.sourced(
                table: changedTable,
                facts: [fact]
            )
        )

        #expect(original != changed)
        #expect(original.table == originalTable)
    }
}
