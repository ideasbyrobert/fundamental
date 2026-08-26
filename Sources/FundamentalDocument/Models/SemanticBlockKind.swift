enum SemanticBlockKind:
    String,
    Codable,
    Sendable
{
    case paragraph
    case heading
    case quote
    case code
    case listItem
    case sceneBreak
    case table
    case image
    case rawHTML
}
