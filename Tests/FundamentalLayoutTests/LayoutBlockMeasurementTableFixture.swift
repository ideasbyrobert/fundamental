import Testing

@testable import FundamentalDocument

extension LayoutBlockMeasurementTests
{
    func emptyTable() throws -> SemanticBlock
    {
        let content = try #require(SemanticTableContent(
            headerRows: [],
            bodyRows: [],
            columnAlignments: []
        ))
        return .table(.semantic(.regular(
            RegularSemanticTable(content: content)
        )))
    }

    func emptyRowTable() throws -> SemanticBlock
    {
        let content = try #require(SemanticTableContent(
            headerRows: [HeaderSemanticTableRow(cells: [])],
            bodyRows: [BodySemanticTableRow(cells: [])],
            columnAlignments: []
        ))
        return .table(.semantic(.regular(
            RegularSemanticTable(content: content)
        )))
    }

    func captionedZeroRowTable() throws -> SemanticBlock
    {
        let content = try #require(SemanticTableContent(
            headerRows: [],
            bodyRows: [],
            columnAlignments: []
        ))
        let caption = SemanticTableCaption(
            firstRun: LayoutFixture.direct("Caption"),
            remainingRuns: []
        )
        return .table(.semantic(.captioned(
            CaptionedSemanticTable(
                content: content,
                caption: caption
            )
        )))
    }
}
