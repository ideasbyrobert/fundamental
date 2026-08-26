enum CanonicalBlockStyle:
    String,
    Codable,
    CaseIterable,
    Sendable
{
    case title
    case heading
    case subheading
    case body
    case monostyled
}
