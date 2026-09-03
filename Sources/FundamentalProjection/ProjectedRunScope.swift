package enum ProjectedRunScope: Equatable, Sendable
{
    case link(String)
    case language(String)
    case linkAndLanguage(
        link: String,
        language: String
    )
}
