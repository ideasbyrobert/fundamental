import AppKit
import FundamentalDocument

@MainActor
enum WritingRunAppearance
{
    static func attributes(
        _ source: SemanticRunAttributes, font: NSFont
    ) -> [NSAttributedString.Key: Any]?
    {
        let traits: Set<SemanticInlineTrait>
        let scopes: SemanticRunScopes?
        switch source
        {
        case let .direct(value):
            traits = value
            scopes = nil
        case let .scoped(value, scoped):
            traits = value
            scopes = scoped
        }
        guard var result = WritingInlineAppearance.attributes(
            traits: traits, font: font
        )
        else
        {
            return nil
        }
        guard let scopes
        else
        {
            return result
        }
        switch scopes
        {
        case let .link(link):
            result[.link] = link.value as NSString
        case let .language(language):
            result[.languageIdentifier] = language.value as NSString
        case let .linkAndLanguage(link, language):
            result[.link] = link.value as NSString
            result[.languageIdentifier] = language.value as NSString
        }
        return result
    }
}
