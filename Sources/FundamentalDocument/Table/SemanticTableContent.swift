package struct SemanticTableContent: Equatable, Sendable
{
    package let headerRows: [HeaderSemanticTableRow]
    package let bodyRows: [BodySemanticTableRow]
    package let columnAlignments: [SemanticTableColumnAlignment]
}
