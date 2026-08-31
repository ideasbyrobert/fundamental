import Testing

@testable import FundamentalDocument

extension SemanticTableEvidenceTests
{
    @Test("canonicalization preserves facts in target hierarchy")
    func canonicalizationPreservesFactsInTargetHierarchy() throws
    {
        let row2 = try Self.row(2)
        let row10 = try Self.row(10)
        let cell2 = try Self.cell(2)
        let cell10 = try Self.cell(10)
        let canonical = try [
            Self.location(target: .table),
            Self.location(target: .row(row2)),
            Self.location(target: .cell(row: row2, cell: cell2)),
            Self.location(target: .cell(row: row2, cell: cell10)),
            Self.location(target: .row(row10)),
            Self.location(target: .cell(row: row10, cell: cell2))
        ]
        let forward = try Self.evidence(canonical)
        let reversed = try Self.evidence(Array(canonical.reversed()))

        #expect(forward == reversed)
        #expect(forward.facts == canonical)
    }

    @Test("fact kinds follow location confidence and repair")
    func factKindsFollowLocationConfidenceAndRepair() throws
    {
        let row = try Self.row(0)
        let cell = try Self.cell(0)
        let target = SemanticTableEvidenceTarget.cell(
            row: row,
            cell: cell
        )
        let location = try Self.location(target: target)
        let confidence = try Self.confidence(
            target: .cell(row: row, cell: cell)
        )
        let repair = try Self.repair(
            target: target,
            kind: .nonpositiveRowSpanNormalizedToOne
        )
        let evidence = try Self.evidence([
            repair,
            confidence,
            location
        ])

        #expect(evidence.facts == [location, confidence, repair])
    }

    @Test("repairs follow frozen declaration order")
    func repairsFollowFrozenDeclarationOrder() throws
    {
        let row = try Self.row(0)
        let cell = try Self.cell(0)
        let target = SemanticTableEvidenceTarget.cell(
            row: row,
            cell: cell
        )
        let kinds: [SemanticTableRepairKind] = [
            .nonpositiveRowSpanNormalizedToOne,
            .nonpositiveColumnSpanNormalizedToOne,
            .contradictoryCellHeaderFlagDiscarded,
            .blankSourceLocationDiscarded
        ]
        let cellRepairs = try kinds.map
        {
            try Self.repair(target: target, kind: $0)
        }
        let header = try Self.repair(
            target: .table,
            kind: .headerRowCountClamped
        )
        let blank = try Self.repair(
            target: .table,
            kind: .blankSourceLocationDiscarded
        )
        let evidence = try Self.evidence(
            cellRepairs.reversed() + [blank, header]
        )

        #expect(evidence.facts == [header, blank] + cellRepairs)
    }
}
