@testable import FundamentalDocument

extension RasterFixture
{
    static func emptyRowTable() -> SemanticBlock
    {
        let content = SemanticTableContent(
            headerRows: [],
            bodyRows: [
                BodySemanticTableRow(cells: []),
                BodySemanticTableRow(cells: [])
            ],
            columnAlignments: [.leading, .trailing]
        )
        return .table(.semantic(.regular(RegularSemanticTable(
            content: content
        ))))
    }
}
