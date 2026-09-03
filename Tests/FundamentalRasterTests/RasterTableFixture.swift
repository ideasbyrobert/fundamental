import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension RasterFixture
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
        let content = SemanticTableContent(
            headerRows: [header],
            bodyRows: [body],
            columnAlignments: [.leading, .center]
        )
        let caption = SemanticTableCaption(
            firstRun: run("Caption"),
            remainingRuns: []
        )
        return .table(.semantic(.captioned(CaptionedSemanticTable(
            content: content,
            caption: caption
        ))))
    }

    static func zeroRowTable() -> SemanticBlock
    {
        let content = SemanticTableContent(
            headerRows: [],
            bodyRows: [],
            columnAlignments: [.leading, .trailing]
        )
        return .table(.semantic(.regular(RegularSemanticTable(
            content: content
        ))))
    }

    static func captionedZeroRowTable() -> SemanticBlock
    {
        let content = SemanticTableContent(
            headerRows: [],
            bodyRows: [],
            columnAlignments: [.leading, .trailing]
        )
        let caption = SemanticTableCaption(
            firstRun: run("Only caption"),
            remainingRuns: []
        )
        return .table(.semantic(.captioned(CaptionedSemanticTable(
            content: content,
            caption: caption
        ))))
    }
}
