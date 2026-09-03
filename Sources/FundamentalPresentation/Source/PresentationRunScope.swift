package enum PresentationRunScope: Equatable, Sendable
{
    case direct
    case link(String)
    case language(String)
    case linkAndLanguage(
        link: String,
        language: String
    )
}
