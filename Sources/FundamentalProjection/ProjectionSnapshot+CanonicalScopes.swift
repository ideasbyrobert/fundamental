import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ scopes: SemanticRunScopes
    ) -> ProjectedRunScope
    {
        switch scopes
        {
        case let .link(link):
            .link(link.value)
        case let .language(language):
            .language(language.value)
        case let .linkAndLanguage(link, language):
            .linkAndLanguage(
                link: link.value,
                language: language.value
            )
        }
    }

}
