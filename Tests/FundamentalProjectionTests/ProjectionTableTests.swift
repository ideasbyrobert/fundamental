import Testing

@testable import FundamentalDocument
@testable import FundamentalProjection

extension ProjectionProseTests
{
    @Test("all table forms retain rows cells captions and evidence")
    func tableFormsRemainExact() throws
    {
        for captioned in [false, true]
        {
            for sourced in [false, true]
            {
                let record = try ProjectionFixture.tableRecord(
                    captioned: captioned,
                    sourced: sourced
                )
                let projection = try ProjectionFixture.projection([
                    .table(record)
                ])
                guard case let .table(_, projected) = projection.firstBlock
                else
                {
                    Issue.record("Expected table")
                    return
                }
                let content = projected.table.content
                #expect(content.headerRows[0].index == 0)
                #expect(content.bodyRows[0].index == 1)
                #expect(content.columnAlignments == [
                    .leading,
                    .center,
                    .trailing,
                    .unspecified
                ])
                guard case let .regular(headRuns, headAlignment)
                    = content.headerRows[0].cells[0],
                      case let .spanning(bodyRuns, bodyAlignment, extent)
                    = content.bodyRows[0].cells[0]
                else
                {
                    Issue.record("Expected exact cells")
                    return
                }
                #expect(headRuns.map(\.text) == ["Head"])
                #expect(headAlignment == .center)
                let headRange = ProjectedUTF16Range(0..<4)
                #expect(headRuns[0].source == .cell(
                    blockID: projection.firstBlock.source.blockID,
                    row: 0,
                    cell: 0,
                    run: 0,
                    range: headRange
                ))
                #expect(bodyRuns.map(\.text) == ["B😀"])
                #expect(bodyAlignment == .trailing)
                let bodyRange = ProjectedUTF16Range(0..<3)
                #expect(bodyRuns[0].source == .cell(
                    blockID: projection.firstBlock.source.blockID,
                    row: 1,
                    cell: 0,
                    run: 0,
                    range: bodyRange
                ))
                #expect(extent.rowCount == 2)
                #expect(extent.columnCount == 1)
                try verifyOuterForm(
                    projected,
                    captioned: captioned,
                    sourced: sourced
                )
            }
        }
    }

}
