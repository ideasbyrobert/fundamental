enum SemanticRoleHint:
    String,
    Codable,
    Sendable
{
    case title
    case heading1
    case heading2
    case heading3
    case heading4
    case heading5
    case heading6
    case body
    case quote
    case code
    case bullet
    case numberedItem
    case sceneBreak
    case caption
}
