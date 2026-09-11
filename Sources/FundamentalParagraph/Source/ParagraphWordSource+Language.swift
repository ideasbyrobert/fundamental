import FundamentalDocument

extension ParagraphWordSource
{
    static func language(
        _ run: SemanticRun,
        default inherited: SemanticLanguageIdentifier
    ) -> SemanticLanguageIdentifier
    {
        switch run
        {
        case .direct:
            inherited
        case let .scoped(value):
            switch value.scopes
            {
            case .link:
                inherited
            case let .language(language):
                language
            case let .linkAndLanguage(_, language):
                language
            }
        }
    }
}
