package struct SemanticTableEvidence: Equatable, Sendable
{
    let firstFact: SemanticTableEvidenceFact
    let remainingFacts: [SemanticTableEvidenceFact]

    init?(
        firstFact: SemanticTableEvidenceFact,
        remainingFacts: [SemanticTableEvidenceFact]
    )
    {
        let facts = [firstFact] + remainingFacts
        guard !Self.containsConflict(facts)
        else
        {
            return nil
        }

        let orderedFacts = facts.sorted(by: Self.precedes)
        self.firstFact = orderedFacts[0]
        self.remainingFacts = Array(orderedFacts.dropFirst())
    }

    package var facts: [SemanticTableEvidenceFact]
    {
        [firstFact] + remainingFacts
    }

    private static func containsConflict(
        _ facts: [SemanticTableEvidenceFact]
    ) -> Bool
    {
        for firstIndex in facts.indices
        {
            for secondIndex in facts.indices
            where secondIndex > firstIndex
            {
                if conflicts(
                    facts[firstIndex],
                    facts[secondIndex]
                )
                {
                    return true
                }
            }
        }
        return false
    }

    private static func conflicts(
        _ first: SemanticTableEvidenceFact,
        _ second: SemanticTableEvidenceFact
    ) -> Bool
    {
        guard target(of: first) == target(of: second)
        else
        {
            return false
        }

        switch (first, second)
        {
        case (.sourceLocation, .sourceLocation):
            return true
        case (.confidence, .confidence):
            return true
        case let (.repair(firstRepair), .repair(secondRepair)):
            return firstRepair.kind == secondRepair.kind
        case let (.sourceLocation, .repair(repair)),
             let (.repair(repair), .sourceLocation):
            return repair.kind == .blankSourceLocationDiscarded
        default:
            return false
        }
    }

    private static func precedes(
        _ first: SemanticTableEvidenceFact,
        _ second: SemanticTableEvidenceFact
    ) -> Bool
    {
        let firstTarget = target(of: first)
        let secondTarget = target(of: second)
        if firstTarget != secondTarget
        {
            return targetPrecedes(firstTarget, secondTarget)
        }

        let firstKind = factKindRank(first)
        let secondKind = factKindRank(second)
        if firstKind != secondKind
        {
            return firstKind < secondKind
        }

        guard case let .repair(firstRepair) = first,
              case let .repair(secondRepair) = second
        else
        {
            return false
        }
        return repairKindRank(firstRepair.kind)
            < repairKindRank(secondRepair.kind)
    }

    private static func target(
        of fact: SemanticTableEvidenceFact
    ) -> SemanticTableEvidenceTarget
    {
        switch fact
        {
        case let .sourceLocation(target, _):
            target
        case let .confidence(target, _):
            switch target
            {
            case .table:
                .table
            case let .cell(row, cell):
                .cell(row: row, cell: cell)
            }
        case let .repair(repair):
            repair.target
        }
    }

    private static func targetPrecedes(
        _ first: SemanticTableEvidenceTarget,
        _ second: SemanticTableEvidenceTarget
    ) -> Bool
    {
        switch (first, second)
        {
        case (.table, .table):
            return false
        case (.table, _):
            return true
        case (_, .table):
            return false
        case let (.row(firstRow), .row(secondRow)):
            return firstRow.value < secondRow.value
        case let (
            .row(firstRow),
            .cell(row: secondRow, cell: _)
        ):
            return firstRow.value <= secondRow.value
        case let (
            .cell(row: firstRow, cell: _),
            .row(secondRow)
        ):
            return firstRow.value < secondRow.value
        case let (
            .cell(row: firstRow, cell: firstCell),
            .cell(row: secondRow, cell: secondCell)
        ):
            if firstRow.value != secondRow.value
            {
                return firstRow.value < secondRow.value
            }
            return firstCell.value < secondCell.value
        }
    }

    private static func factKindRank(
        _ fact: SemanticTableEvidenceFact
    ) -> Int
    {
        switch fact
        {
        case .sourceLocation:
            0
        case .confidence:
            1
        case .repair:
            2
        }
    }

    private static func repairKindRank(
        _ kind: SemanticTableRepairKind
    ) -> Int
    {
        switch kind
        {
        case .nonpositiveRowSpanNormalizedToOne:
            0
        case .nonpositiveColumnSpanNormalizedToOne:
            1
        case .headerRowCountClamped:
            2
        case .contradictoryCellHeaderFlagDiscarded:
            3
        case .blankSourceLocationDiscarded:
            4
        }
    }
}
