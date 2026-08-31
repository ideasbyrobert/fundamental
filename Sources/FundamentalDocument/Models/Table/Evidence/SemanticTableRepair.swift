struct SemanticTableRepair: Equatable, Sendable
{
    let target: SemanticTableEvidenceTarget
    let kind: SemanticTableRepairKind

    init?(
        target: SemanticTableEvidenceTarget,
        kind: SemanticTableRepairKind
    )
    {
        guard Self.admits(
            target: target,
            kind: kind
        )
        else
        {
            return nil
        }

        self.target = target
        self.kind = kind
    }

    private static func admits(
        target: SemanticTableEvidenceTarget,
        kind: SemanticTableRepairKind
    ) -> Bool
    {
        switch (target, kind)
        {
        case (.table, .headerRowCountClamped):
            true
        case (
            .cell(row: _, cell: _),
            .nonpositiveRowSpanNormalizedToOne
        ), (
            .cell(row: _, cell: _),
            .nonpositiveColumnSpanNormalizedToOne
        ), (
            .cell(row: _, cell: _),
            .contradictoryCellHeaderFlagDiscarded
        ):
            true
        case (_, .blankSourceLocationDiscarded):
            true
        default:
            false
        }
    }
}
