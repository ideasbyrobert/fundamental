import Testing

@testable import FundamentalDocument

extension RasterFixture
{
    static func emptyRowTable() throws -> SemanticBlock
    {
        let content = try #require(SemanticTableContent(
            headerRows: [],
            bodyRows: [
                BodySemanticTableRow(cells: []),
                BodySemanticTableRow(cells: [])
            ],
            columnAlignments: [.leading, .trailing]
        ))
        return .table(.semantic(.regular(RegularSemanticTable(
            content: content
        ))))
    }
}
