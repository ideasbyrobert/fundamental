import Testing

@testable import FundamentalDocument

extension PresentationFixture
{
    static func table() throws -> SemanticBlock
    {
        let extent = try #require(SemanticTableCellExtent(
            rowCount: 1,
            columnCount: 2
        ))
        let header = HeaderSemanticTableRow(cells: [
            .spanning(SpanningSemanticTableCell(
                runs: [run("Header")],
                alignment: .center,
                extent: extent
            ))
        ])
        let body = BodySemanticTableRow(cells: [
            .regular(RegularSemanticTableCell(
                runs: [run("Left")],
                alignment: .unspecified
            )),
            .regular(RegularSemanticTableCell(
                runs: [run("Right")],
                alignment: .trailing
            ))
        ])
        let content = try #require(SemanticTableContent(
            headerRows: [header],
            bodyRows: [body],
            columnAlignments: [.leading, .center]
        ))
        let caption = SemanticTableCaption(
            firstRun: run("Caption"),
            remainingRuns: []
        )
        return .table(.semantic(.captioned(CaptionedSemanticTable(
            content: content,
            caption: caption
        ))))
    }
}
