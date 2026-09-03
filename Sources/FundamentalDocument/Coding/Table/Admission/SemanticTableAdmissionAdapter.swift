enum SemanticTableAdmissionAdapter
{
    static func admit(
        _ legacy: LegacySemanticTable
    ) -> SemanticTableAdmission?
    {
        guard let confidence = SemanticTableConfidence(
            legacy.confidence
        )
        else
        {
            return nil
        }

        let headerRowCount = normalizedHeaderRowCount(legacy)
        var headerRows: [HeaderSemanticTableRow] = []
        var bodyRows: [BodySemanticTableRow] = []
        var evidence: [SemanticTableEvidenceFact] = [
            .confidence(
                target: .table,
                confidence: confidence
            )
        ]

        if headerRowCount != legacy.headerRowCount
        {
            guard let repair = headerRowCountRepair()
            else
            {
                return nil
            }
            evidence.append(repair)
        }

        if let sourceLocation = legacy.sourceLocation
        {
            guard let sourceEvidence = sourceEvidence(sourceLocation)
            else
            {
                return nil
            }
            evidence.append(sourceEvidence)
        }

        for (offset, legacyRow) in legacy.rows.enumerated()
        {
            guard let rowIndex = SemanticTableRowIndex(offset)
            else
            {
                return nil
            }
            let role = role(
                at: offset,
                headerRowCount: headerRowCount
            )
            guard let admission = SemanticTableRowAdmissionAdapter.admit(
                legacyRow,
                rowIndex: rowIndex,
                role: role
            )
            else
            {
                return nil
            }

            switch (role, admission.row)
            {
            case let (.header, .header(row)):
                headerRows.append(row)
            case let (.body, .body(row)):
                bodyRows.append(row)
            default:
                return nil
            }
            evidence.append(contentsOf: admission.evidence)
        }

        guard let content = SemanticTableContent(
            headerRows: headerRows,
            bodyRows: bodyRows,
            columnAlignments: legacy.columnAlignments
        )
        else
        {
            return nil
        }
        return SemanticTableAdmission(
            table: table(
                content: content,
                captionRuns: legacy.caption
            ),
            evidence: evidence
        )
    }

    private static func normalizedHeaderRowCount(
        _ legacy: LegacySemanticTable
    ) -> Int
    {
        min(
            max(0, legacy.headerRowCount),
            legacy.rows.count
        )
    }

    private static func role(
        at rowIndex: Int,
        headerRowCount: Int
    ) -> SemanticTableRowAdmissionRole
    {
        if rowIndex < headerRowCount
        {
            return .header
        }
        return .body
    }

    private static func table(
        content: SemanticTableContent,
        captionRuns: [SemanticRun]?
    ) -> SemanticTable
    {
        guard let captionRuns,
              let firstRun = captionRuns.first
        else
        {
            return .regular(
                RegularSemanticTable(content: content)
            )
        }

        let caption = SemanticTableCaption(
            firstRun: firstRun,
            remainingRuns: Array(captionRuns.dropFirst())
        )
        return .captioned(CaptionedSemanticTable(
            content: content,
            caption: caption
        ))
    }

    private static func headerRowCountRepair()
        -> SemanticTableEvidenceFact?
    {
        guard let repair = SemanticTableRepair(
            target: .table,
            kind: .headerRowCountClamped
        )
        else
        {
            return nil
        }
        return .repair(repair)
    }

    private static func sourceEvidence(
        _ value: String
    ) -> SemanticTableEvidenceFact?
    {
        if let location = SemanticTableSourceLocation(value)
        {
            return .sourceLocation(
                target: .table,
                location: location
            )
        }

        guard let repair = SemanticTableRepair(
            target: .table,
            kind: .blankSourceLocationDiscarded
        )
        else
        {
            return nil
        }
        return .repair(repair)
    }
}
