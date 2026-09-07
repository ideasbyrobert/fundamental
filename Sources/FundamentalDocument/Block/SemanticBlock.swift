package enum SemanticBlock: Equatable, Sendable
{
    case paragraph(SemanticParagraph)
    case heading(SemanticHeading)
    case listItem(SemanticListItem)
    case code(SemanticCodeBlock)
    case table(SemanticTableRecord)

    var kind: SemanticBlockKind
    {
        switch self
        {
        case .paragraph:
            .paragraph
        case .heading:
            .heading
        case .listItem:
            .listItem
        case .code:
            .code
        case .table:
            .table
        }
    }
}
