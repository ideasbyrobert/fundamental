package enum SemanticRunScopeAssignment: Equatable, Sendable
{
    case link(SemanticLinkDestination?)
    case language(SemanticLanguageIdentifier?)

    func applying(to attributes: SemanticRunAttributes) -> SemanticRunAttributes
    {
        let traits: Set<SemanticInlineTrait>
        var link: SemanticLinkDestination?
        var language: SemanticLanguageIdentifier?
        switch attributes
        {
        case let .direct(value):
            traits = value
        case let .scoped(value, scopes):
            traits = value
            switch scopes
            {
            case let .link(value):
                link = value
            case let .language(value):
                language = value
            case let .linkAndLanguage(target, identifier):
                link = target
                language = identifier
            }
        }
        switch self
        {
        case let .link(value):
            link = value
        case let .language(value):
            language = value
        }
        let scopes: SemanticRunScopes
        if let link, let language
        {
            scopes = .linkAndLanguage(link: link, language: language)
        }
        else if let link
        {
            scopes = .link(link)
        }
        else if let language
        {
            scopes = .language(language)
        }
        else
        {
            return .direct(traits: traits)
        }
        return .scoped(traits: traits, scopes: scopes)
    }
}
