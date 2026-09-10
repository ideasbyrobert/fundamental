import FundamentalDocument

enum WritingScopeKind: String, CaseIterable, Sendable
{
    case link = "FundamentalLinkScope"
    case language = "FundamentalLanguageScope"

    func setting(_ value: String) -> SemanticRunScopeAssignment?
    {
        switch self
        {
        case .link:
            SemanticLinkDestination(value).map
            {
                .link($0)
            }
        case .language:
            SemanticLanguageIdentifier(value).map
            {
                .language($0)
            }
        }
    }

    var removal: SemanticRunScopeAssignment
    {
        switch self
        {
        case .link: .link(nil)
        case .language: .language(nil)
        }
    }
}
