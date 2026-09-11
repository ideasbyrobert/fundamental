import FundamentalDocument

package struct ResolvedWordScope: Equatable, Sendable
{
    package let range: Range<Int>
    package let language: SemanticLanguageIdentifier
    package let fragments: [WordRunFragment]
}
