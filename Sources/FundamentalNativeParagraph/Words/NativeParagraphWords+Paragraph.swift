import FundamentalDocument
import FundamentalParagraph

extension NativeParagraphWords
{
    package init(
        _ paragraph: SemanticParagraph, language: NativeWordLanguage,
        defaultLanguage: String
    ) throws
    {
        guard let identifier = SemanticLanguageIdentifier(defaultLanguage)
        else
        {
            throw WordScopeFailure.invalidDefaultLanguage(defaultLanguage)
        }
        try self.init(
            source: ParagraphWordSource(
                paragraph, defaultLanguage: identifier
            ),
            language: language
        )
    }
}
