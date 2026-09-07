import Testing

@testable import FundamentalDocument

extension BlockRecordTestValue
{
    static func tables() throws -> [SemanticTableRecord]
    {
        let cell = SemanticTableCell.regular(RegularSemanticTableCell(
            runs: try runs()
        ))
        let content = try #require(SemanticTableContent(
            headerRows: [HeaderSemanticTableRow(cells: [cell])],
            bodyRows: [BodySemanticTableRow(cells: [cell])],
            columnAlignments: [.center]
        ))
        let tables: [SemanticTable] = [
            .regular(RegularSemanticTable(content: content)),
            .captioned(CaptionedSemanticTable(
                content: content,
                caption: SemanticTableCaption(
                    firstRun: SemanticRun(text: "Caption Հայերեն"),
                    remainingRuns: try runs()
                )
            ))
        ]
        let confidence = try #require(SemanticTableConfidence(0.75))
        let location = try #require(SemanticTableSourceLocation("page 3"))
        let evidence = try #require(SemanticTableEvidence(
            firstFact: .confidence(
                target: .table,
                confidence: confidence
            ),
            remainingFacts: [.sourceLocation(
                target: .table,
                location: location
            )]
        ))
        return try tables.flatMap
        {
            [.semantic($0), .sourced(try #require(SourcedSemanticTable(
                table: $0,
                evidence: evidence
            )))]
        }
    }
}
