enum SemanticRunScopes: Equatable, Sendable
{
    case link(SemanticLinkDestination)
    case language(SemanticLanguageIdentifier)
    case linkAndLanguage(
        link: SemanticLinkDestination,
        language: SemanticLanguageIdentifier
    )
}
