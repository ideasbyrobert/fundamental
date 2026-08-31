enum SemanticTableRowAdmissionAdapter
{
    static func admit(
        _ legacy: LegacySemanticTableRow,
        rowIndex: SemanticTableRowIndex,
        role: SemanticTableRowAdmissionRole
    ) -> SemanticTableRowAdmission?
    {
        var cells: [SemanticTableCell] = []
        var evidence: [SemanticTableEvidenceFact] = []

        for (offset, legacyCell) in legacy.cells.enumerated()
        {
            guard let cellIndex = SemanticTableCellIndex(offset),
                  let admission = SemanticTableCellAdmissionAdapter.admit(
                      legacyCell,
                      rowIndex: rowIndex,
                      cellIndex: cellIndex
                  )
            else
            {
                return nil
            }

            cells.append(admission.cell)
            evidence.append(contentsOf: admission.evidence)

            if contradicts(
                admission.legacyHeaderClaim,
                role: role
            )
            {
                guard let repair = contradictionRepair(
                    rowIndex: rowIndex,
                    cellIndex: cellIndex
                )
                else
                {
                    return nil
                }
                evidence.append(repair)
            }
        }

        if let sourceLocation = legacy.sourceLocation
        {
            guard let sourceEvidence = sourceEvidence(
                sourceLocation,
                rowIndex: rowIndex
            )
            else
            {
                return nil
            }
            evidence.append(sourceEvidence)
        }

        return SemanticTableRowAdmission(
            row: row(cells: cells, role: role),
            evidence: evidence
        )
    }

    private static func row(
        cells: [SemanticTableCell],
        role: SemanticTableRowAdmissionRole
    ) -> SemanticTableRow
    {
        switch role
        {
        case .header:
            .header(HeaderSemanticTableRow(cells: cells))
        case .body:
            .body(BodySemanticTableRow(cells: cells))
        }
    }

    private static func contradicts(
        _ legacyHeaderClaim: Bool,
        role: SemanticTableRowAdmissionRole
    ) -> Bool
    {
        switch role
        {
        case .header:
            !legacyHeaderClaim
        case .body:
            legacyHeaderClaim
        }
    }

    private static func contradictionRepair(
        rowIndex: SemanticTableRowIndex,
        cellIndex: SemanticTableCellIndex
    ) -> SemanticTableEvidenceFact?
    {
        let target = SemanticTableEvidenceTarget.cell(
            row: rowIndex,
            cell: cellIndex
        )
        guard let repair = SemanticTableRepair(
            target: target,
            kind: .contradictoryCellHeaderFlagDiscarded
        )
        else
        {
            return nil
        }

        return .repair(repair)
    }

    private static func sourceEvidence(
        _ value: String,
        rowIndex: SemanticTableRowIndex
    ) -> SemanticTableEvidenceFact?
    {
        let target = SemanticTableEvidenceTarget.row(rowIndex)
        if let location = SemanticTableSourceLocation(value)
        {
            return .sourceLocation(
                target: target,
                location: location
            )
        }

        guard let repair = SemanticTableRepair(
            target: target,
            kind: .blankSourceLocationDiscarded
        )
        else
        {
            return nil
        }

        return .repair(repair)
    }
}
