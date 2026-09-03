package struct ProjectedTableContent: Equatable, Sendable
{
    package let headerRows: [ProjectedTableRow]
    package let bodyRows: [ProjectedTableRow]
    package let columnAlignments: [ProjectedTableColumnAlignment]
}
