package enum SemanticInlineTrait:
    String,
    Codable,
    Hashable,
    Sendable
{
    case strong
    case emphasis
    case underline
    case strikethrough
    case inlineCode
    case superscript
    case subscriptText = "subscript"
}
