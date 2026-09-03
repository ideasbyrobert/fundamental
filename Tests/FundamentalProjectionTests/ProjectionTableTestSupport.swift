import Testing

@testable import FundamentalDocument

extension ProjectionFixture
{
    static func tableRecord(
        captioned: Bool,
        sourced: Bool
    ) throws -> SemanticTableRecord
    {
        let extent = try #require(SemanticTableCellExtent(
            rowCount: 2,
            columnCount: 1
        ))
        let content = SemanticTableContent(
            headerRows: [HeaderSemanticTableRow(cells: [
                .regular(RegularSemanticTableCell(
                    runs: [direct("Head")],
                    alignment: .center
                ))
            ])],
            bodyRows: [BodySemanticTableRow(cells: [
                .spanning(SpanningSemanticTableCell(
                    runs: [try scoped("B😀")],
                    alignment: .trailing,
                    extent: extent
                ))
            ])],
            columnAlignments: [
                .leading,
                .center,
                .trailing,
                .unspecified
            ]
        )
        let table: SemanticTable
        if captioned
        {
            table = .captioned(CaptionedSemanticTable(
                content: content,
                caption: SemanticTableCaption(
                    firstRun: direct("C😀"),
                    remainingRuns: []
                )
            ))
        }
        else
        {
            table = .regular(RegularSemanticTable(content: content))
        }
        guard sourced
        else
        {
            return .semantic(table)
        }
        return .sourced(try #require(SourcedSemanticTable(
            table: table,
            evidence: try evidence()
        )))
    }
}
