import Testing

@testable import FundamentalDocument

@Suite("A semantic table repair")
struct SemanticTableRepairTests
{
    @Test("applicable repairs preserve their facts")
    func applicableRepairsPreserveTheirFacts() throws
    {
        let row = try #require(SemanticTableRowIndex(1))
        let cell = try #require(SemanticTableCellIndex(2))
        let cellTarget = SemanticTableEvidenceTarget.cell(
            row: row,
            cell: cell
        )
        let pairs: [(SemanticTableEvidenceTarget, SemanticTableRepairKind)] = [
            (.table, .headerRowCountClamped),
            (cellTarget, .nonpositiveRowSpanNormalizedToOne),
            (cellTarget, .nonpositiveColumnSpanNormalizedToOne),
            (cellTarget, .contradictoryCellHeaderFlagDiscarded),
            (.table, .blankSourceLocationDiscarded),
            (.row(row), .blankSourceLocationDiscarded),
            (cellTarget, .blankSourceLocationDiscarded)
        ]

        for (target, kind) in pairs
        {
            let repair = try #require(
                SemanticTableRepair(target: target, kind: kind)
            )

            #expect(repair.target == target)
            #expect(repair.kind == kind)
        }
    }

    @Test("inapplicable target and kind pairs are refused")
    func inapplicableTargetAndKindPairsAreRefused() throws
    {
        let row = try #require(SemanticTableRowIndex(1))
        let cell = try #require(SemanticTableCellIndex(2))
        let cellTarget = SemanticTableEvidenceTarget.cell(
            row: row,
            cell: cell
        )
        let pairs: [(SemanticTableEvidenceTarget, SemanticTableRepairKind)] = [
            (.table, .nonpositiveRowSpanNormalizedToOne),
            (.table, .nonpositiveColumnSpanNormalizedToOne),
            (.table, .contradictoryCellHeaderFlagDiscarded),
            (.row(row), .nonpositiveRowSpanNormalizedToOne),
            (.row(row), .nonpositiveColumnSpanNormalizedToOne),
            (.row(row), .headerRowCountClamped),
            (.row(row), .contradictoryCellHeaderFlagDiscarded),
            (cellTarget, .headerRowCountClamped)
        ]

        for (target, kind) in pairs
        {
            #expect(
                SemanticTableRepair(target: target, kind: kind) == nil
            )
        }
    }
}
