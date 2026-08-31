enum SemanticTableCellAdmissionAdapter
{
    static func admit(
        _ legacy: LegacySemanticTableCell,
        rowIndex: SemanticTableRowIndex,
        cellIndex: SemanticTableCellIndex
    ) -> SemanticTableCellAdmission?
    {
        guard let confidence = SemanticTableConfidence(
            legacy.confidence
        )
        else
        {
            return nil
        }

        let target = SemanticTableEvidenceTarget.cell(
            row: rowIndex,
            cell: cellIndex
        )
        let confidenceTarget = SemanticTableConfidenceTarget.cell(
            row: rowIndex,
            cell: cellIndex
        )
        let rowCount = max(1, legacy.rowSpan)
        let columnCount = max(1, legacy.columnSpan)
        var evidence: [SemanticTableEvidenceFact] = [
            .confidence(
                target: confidenceTarget,
                confidence: confidence
            )
        ]

        if legacy.rowSpan <= 0
        {
            guard let repair = repair(
                target: target,
                kind: .nonpositiveRowSpanNormalizedToOne
            )
            else
            {
                return nil
            }
            evidence.append(repair)
        }

        if legacy.columnSpan <= 0
        {
            guard let repair = repair(
                target: target,
                kind: .nonpositiveColumnSpanNormalizedToOne
            )
            else
            {
                return nil
            }
            evidence.append(repair)
        }

        if let sourceLocation = legacy.sourceLocation
        {
            guard let sourceEvidence = sourceEvidence(
                sourceLocation,
                target: target
            )
            else
            {
                return nil
            }
            evidence.append(sourceEvidence)
        }

        guard let cell = cell(
            legacy,
            rowCount: rowCount,
            columnCount: columnCount
        )
        else
        {
            return nil
        }

        return SemanticTableCellAdmission(
            cell: cell,
            legacyHeaderClaim: legacy.isHeader,
            evidence: evidence
        )
    }

    private static func cell(
        _ legacy: LegacySemanticTableCell,
        rowCount: Int,
        columnCount: Int
    ) -> SemanticTableCell?
    {
        if rowCount == 1,
           columnCount == 1
        {
            return .regular(
                RegularSemanticTableCell(
                    runs: legacy.runs,
                    alignment: legacy.alignment
                )
            )
        }

        guard let extent = SemanticTableCellExtent(
            rowCount: rowCount,
            columnCount: columnCount
        )
        else
        {
            return nil
        }

        return .spanning(
            SpanningSemanticTableCell(
                runs: legacy.runs,
                alignment: legacy.alignment,
                extent: extent
            )
        )
    }

    private static func sourceEvidence(
        _ value: String,
        target: SemanticTableEvidenceTarget
    ) -> SemanticTableEvidenceFact?
    {
        if let location = SemanticTableSourceLocation(value)
        {
            return .sourceLocation(
                target: target,
                location: location
            )
        }

        return repair(
            target: target,
            kind: .blankSourceLocationDiscarded
        )
    }

    private static func repair(
        target: SemanticTableEvidenceTarget,
        kind: SemanticTableRepairKind
    ) -> SemanticTableEvidenceFact?
    {
        guard let repair = SemanticTableRepair(
            target: target,
            kind: kind
        )
        else
        {
            return nil
        }

        return .repair(repair)
    }
}
