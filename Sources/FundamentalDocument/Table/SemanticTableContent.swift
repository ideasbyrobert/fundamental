package struct SemanticTableContent: Equatable, Sendable
{
    package let headerRows: [HeaderSemanticTableRow]
    package let bodyRows: [BodySemanticTableRow]
    package let columnAlignments: [SemanticTableColumnAlignment]

    package init?(
        headerRows: [HeaderSemanticTableRow],
        bodyRows: [BodySemanticTableRow],
        columnAlignments: [SemanticTableColumnAlignment]
    )
    {
        let total = headerRows.count.addingReportingOverflow(
            bodyRows.count
        )
        guard !total.overflow
        else
        {
            return nil
        }
        for (rowIndex, row) in headerRows.enumerated()
        {
            guard Self.cells(
                row.cells,
                fitAt: rowIndex,
                totalRowCount: total.partialValue
            )
            else
            {
                return nil
            }
        }
        for (offset, row) in bodyRows.enumerated()
        {
            let index = headerRows.count.addingReportingOverflow(offset)
            guard !index.overflow,
                  Self.cells(
                      row.cells,
                      fitAt: index.partialValue,
                      totalRowCount: total.partialValue
                  )
            else
            {
                return nil
            }
        }

        self.headerRows = headerRows
        self.bodyRows = bodyRows
        self.columnAlignments = columnAlignments
    }

    private static func cells(
        _ cells: [SemanticTableCell],
        fitAt rowIndex: Int,
        totalRowCount: Int
    ) -> Bool
    {
        let remainingRowCount = totalRowCount - rowIndex
        return cells.allSatisfy
        {
            $0.rowCount <= remainingRowCount
        }
    }
}
