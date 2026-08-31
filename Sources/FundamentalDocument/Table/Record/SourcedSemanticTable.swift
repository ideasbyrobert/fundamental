struct SourcedSemanticTable: Equatable, Sendable
{
    let table: SemanticTable
    let evidence: SemanticTableEvidence

    init?(
        table: SemanticTable,
        evidence: SemanticTableEvidence
    )
    {
        guard evidence.facts.allSatisfy(
            { Self.admits($0, in: table) }
        )
        else
        {
            return nil
        }

        self.table = table
        self.evidence = evidence
    }

    private static func admits(
        _ fact: SemanticTableEvidenceFact,
        in table: SemanticTable
    ) -> Bool
    {
        let target = target(of: fact)
        guard targetExists(target, in: table.content)
        else
        {
            return false
        }

        guard case let .repair(repair) = fact
        else
        {
            return true
        }

        switch repair.kind
        {
        case .nonpositiveRowSpanNormalizedToOne:
            guard let cell = repairedCell(
                repair,
                in: table.content
            )
            else
            {
                return false
            }
            return cell.rowCount == 1
        case .nonpositiveColumnSpanNormalizedToOne:
            guard let cell = repairedCell(
                repair,
                in: table.content
            )
            else
            {
                return false
            }
            return cell.columnCount == 1
        case .headerRowCountClamped,
             .contradictoryCellHeaderFlagDiscarded,
             .blankSourceLocationDiscarded:
            return true
        }
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

    private static func targetExists(
        _ target: SemanticTableEvidenceTarget,
        in content: SemanticTableContent
    ) -> Bool
    {
        switch target
        {
        case .table:
            true
        case let .row(row):
            rowExists(row, in: content)
        case let .cell(row, cell):
            semanticCell(
                row: row,
                cell: cell,
                in: content
            ) != nil
        }
    }

    private static func rowExists(
        _ row: SemanticTableRowIndex,
        in content: SemanticTableContent
    ) -> Bool
    {
        if row.value < content.headerRows.count
        {
            return true
        }
        let bodyIndex = row.value - content.headerRows.count
        return bodyIndex < content.bodyRows.count
    }

    private static func repairedCell(
        _ repair: SemanticTableRepair,
        in content: SemanticTableContent
    ) -> SemanticTableCell?
    {
        guard case let .cell(row, cell) = repair.target
        else
        {
            return nil
        }
        return semanticCell(
            row: row,
            cell: cell,
            in: content
        )
    }

    private static func semanticCell(
        row: SemanticTableRowIndex,
        cell: SemanticTableCellIndex,
        in content: SemanticTableContent
    ) -> SemanticTableCell?
    {
        let cells: [SemanticTableCell]
        if row.value < content.headerRows.count
        {
            cells = content.headerRows[row.value].cells
        }
        else
        {
            let bodyIndex = row.value - content.headerRows.count
            guard bodyIndex < content.bodyRows.count
            else
            {
                return nil
            }
            cells = content.bodyRows[bodyIndex].cells
        }

        guard cell.value < cells.count
        else
        {
            return nil
        }
        return cells[cell.value]
    }
}
