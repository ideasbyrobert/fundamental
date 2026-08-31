struct SemanticTableContent: Equatable, Sendable
{
    let headerRows: [HeaderSemanticTableRow]
    let bodyRows: [BodySemanticTableRow]
    let columnAlignments: [SemanticTableColumnAlignment]
}
