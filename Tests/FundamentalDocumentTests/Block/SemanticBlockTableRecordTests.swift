import Testing

@testable import FundamentalDocument

extension SemanticBlockTests
{
    static func emptyTableRecord() throws -> SemanticTableRecord
    {
        .semantic(
            .regular(
                RegularSemanticTable(
                    content: try #require(SemanticTableContent(
                        headerRows: [],
                        bodyRows: [],
                        columnAlignments: []
                    ))
                )
            )
        )
    }

    @Test("the table form preserves its sourced evidence record")
    func tableFormPreservesSourcedEvidence() throws
    {
        let table = SemanticTable.regular(
            RegularSemanticTable(
                content: try #require(SemanticTableContent(
                    headerRows: [],
                    bodyRows: [],
                    columnAlignments: []
                ))
            )
        )
        let confidence = try #require(
            SemanticTableConfidence(0.75)
        )
        let evidence = try #require(
            SemanticTableEvidence(
                firstFact: .confidence(
                    target: .table,
                    confidence: confidence
                ),
                remainingFacts: []
            )
        )
        let sourced = try #require(
            SourcedSemanticTable(
                table: table,
                evidence: evidence
            )
        )
        let record = SemanticTableRecord.sourced(sourced)
        let block = SemanticBlock.table(record)

        guard case let .table(actualRecord) = block,
              case let .sourced(actualSourced) = actualRecord
        else
        {
            Issue.record("Expected a sourced table block")
            return
        }

        #expect(actualRecord == record)
        #expect(actualSourced.table == table)
        #expect(actualSourced.evidence == evidence)
    }
}
