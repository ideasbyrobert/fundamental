import Testing

@testable import FundamentalDocument

extension SemanticTableAdmissionTests
{
    @Test("caption occupancy selects the exact table form")
    func captionOccupancySelectsExactTableForm() throws
    {
        let regularCaptions: [[SemanticRun]?] = [nil, []]
        for caption in regularCaptions
        {
            let admission = try Self.admit(Self.table(caption: caption))
            guard case .regular = admission.table
            else
            {
                Issue.record("Expected a regular table")
                return
            }
        }
        let captionedRuns = [
            [SemanticRun(text: "")],
            [
                SemanticRun(text: "First"),
                SemanticRun(text: "Second", traits: [.strong])
            ]
        ]
        for runs in captionedRuns
        {
            let admission = try Self.admit(Self.table(caption: runs))
            guard case let .captioned(table) = admission.table
            else
            {
                Issue.record("Expected a captioned table")
                return
            }
            #expect(table.caption.runs == runs)
        }
    }

    @Test("normalized header counts supply exact row roles")
    func normalizedHeaderCountsSupplyExactRowRoles() throws
    {
        let firstRow = try #require(SemanticTableRowIndex(0))
        let secondRow = try #require(SemanticTableRowIndex(1))
        let cell = try #require(SemanticTableCellIndex(0))
        for headerRowCount in 0 ... 2
        {
            let rows = (0 ..< 2).map
            {
                Self.row(
                    "Row \($0)",
                    isHeader: $0 >= headerRowCount
                )
            }
            let admission = try Self.admit(Self.table(
                rows: rows,
                headerRowCount: headerRowCount
            ))

            #expect(
                admission.table.content.headerRows.count
                    == headerRowCount
            )
            #expect(
                admission.table.content.bodyRows.count
                    == 2 - headerRowCount
            )
            let contradictionTargets = admission.evidence.compactMap
            { fact -> SemanticTableEvidenceTarget? in
                guard case let .repair(repair) = fact
                else
                {
                    return nil
                }
                guard repair.kind
                        == .contradictoryCellHeaderFlagDiscarded
                else
                {
                    return nil
                }
                return repair.target
            }
            #expect(contradictionTargets == [
                .cell(row: firstRow, cell: cell),
                .cell(row: secondRow, cell: cell)
            ])
            #expect(!admission.evidence.contains
            {
                guard case let .repair(repair) = $0
                else
                {
                    return false
                }
                return repair.kind == .headerRowCountClamped
            })
        }
    }
}
