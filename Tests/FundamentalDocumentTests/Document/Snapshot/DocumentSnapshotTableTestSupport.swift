import Testing

@testable import FundamentalDocument

extension DocumentSnapshotTests
{
    static func tableRecord(
        _ form: DocumentSnapshotTableForm
    ) throws -> SemanticTableRecord
    {
        let regular = SourcedSemanticTableTests.table()
        let captioned = SemanticTableRecordTests.captionedTable()
        let table: SemanticTable
        switch form
        {
        case .semanticRegular, .sourcedRegular:
            table = regular
        case .semanticCaptioned, .sourcedCaptioned:
            table = captioned
        }

        switch form
        {
        case .semanticRegular, .semanticCaptioned:
            return .semantic(table)
        case .sourcedRegular, .sourcedCaptioned:
            let fact = try SemanticTableEvidenceTests.confidence(
                target: .table
            )
            return .sourced(try SourcedSemanticTableTests.sourced(
                table: table,
                facts: [fact]
            ))
        }
    }

    static func tableBlock(
        _ form: DocumentSnapshotTableForm = .semanticRegular
    ) throws -> SemanticBlock
    {
        .table(try tableRecord(form))
    }
}
