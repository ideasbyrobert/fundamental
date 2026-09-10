import FundamentalDocument

extension WritingScopeKind
{
    func assignment(in attributes: SemanticRunAttributes)
        -> SemanticRunScopeAssignment
    {
        guard case let .scoped(_, scopes) = attributes
        else
        {
            return removal
        }
        switch (self, scopes)
        {
        case let (.link, .link(value)),
             let (.link, .linkAndLanguage(value, _)):
            return .link(value)
        case let (.language, .language(value)),
             let (.language, .linkAndLanguage(_, value)):
            return .language(value)
        default:
            return removal
        }
    }

    func value(of assignment: SemanticRunScopeAssignment) -> String?
    {
        switch (self, assignment)
        {
        case let (.link, .link(value)): value?.value
        case let (.language, .language(value)): value?.value
        default: nil
        }
    }
}
