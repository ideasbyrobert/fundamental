import Testing

@testable import FundamentalDocument

extension LayoutFixture
{
    static func table(
        captioned: Bool
    ) throws -> SemanticTableRecord
    {
        let wide = try #require(SemanticTableCellExtent(
            rowCount: 1,
            columnCount: 2
        ))
        let tall = try #require(SemanticTableCellExtent(
            rowCount: 2,
            columnCount: 1
        ))
        let content = try #require(SemanticTableContent(
            headerRows: [HeaderSemanticTableRow(cells: [
                .regular(RegularSemanticTableCell(
                    runs: [direct("Head")],
                    alignment: .leading
                )),
                .spanning(SpanningSemanticTableCell(
                    runs: [direct("Wide")],
                    alignment: .center,
                    extent: wide
                ))
            ])],
            bodyRows: [
                BodySemanticTableRow(cells: [
                    .spanning(SpanningSemanticTableCell(
                        runs: [try scoped("B😀")],
                        alignment: .trailing,
                        extent: tall
                    )),
                    .regular(RegularSemanticTableCell(
                        runs: [direct("Tail")],
                        alignment: .unspecified
                    ))
                ]),
                BodySemanticTableRow(cells: [
                    .regular(RegularSemanticTableCell(
                        runs: [direct("After")],
                        alignment: .leading
                    ))
                ])
            ],
            columnAlignments: [.leading, .center, .trailing]
        ))
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
        return .semantic(table)
    }
}
