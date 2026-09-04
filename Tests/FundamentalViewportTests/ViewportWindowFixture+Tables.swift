import Testing

@testable import FundamentalDocument

extension ViewportWindowFixture
{
    static func tableBlocks() throws -> [SemanticBlock]
    {
        let regularContent = try #require(SemanticTableContent(
            headerRows: [HeaderSemanticTableRow(cells: [cell("Head")])],
            bodyRows: [BodySemanticTableRow(cells: [cell("Body")])],
            columnAlignments: [.leading]
        ))
        let regular = SemanticTable.regular(
            RegularSemanticTable(content: regularContent)
        )
        let captioned = SemanticTable.captioned(
            CaptionedSemanticTable(
                content: regularContent,
                caption: SemanticTableCaption(
                    firstRun: run("Caption 👩🏽‍💻"),
                    remainingRuns: []
                )
            )
        )
        let span = try #require(SemanticTableCellExtent(
            rowCount: 1,
            columnCount: 2
        ))
        let spanningContent = try #require(SemanticTableContent(
            headerRows: [],
            bodyRows: [BodySemanticTableRow(cells: [
                .spanning(SpanningSemanticTableCell(
                    runs: [run("Wide")],
                    alignment: .center,
                    extent: span
                ))
            ])],
            columnAlignments: [.leading, .trailing]
        ))
        let spanning = SemanticTable.regular(
            RegularSemanticTable(content: spanningContent)
        )
        return [
            table(regular),
            table(captioned),
            table(spanning),
            try emptyTable(rows: false),
            try emptyTable(rows: true)
        ]
    }

    private static func cell(_ text: String) -> SemanticTableCell
    {
        .regular(RegularSemanticTableCell(
            runs: [run(text)],
            alignment: .leading
        ))
    }

    private static func table(_ value: SemanticTable) -> SemanticBlock
    {
        .table(.semantic(value))
    }

    private static func emptyTable(rows: Bool) throws -> SemanticBlock
    {
        let content = try #require(SemanticTableContent(
            headerRows: rows ? [HeaderSemanticTableRow(cells: [])] : [],
            bodyRows: rows ? [BodySemanticTableRow(cells: [])] : [],
            columnAlignments: []
        ))
        return table(.regular(RegularSemanticTable(content: content)))
    }
}
