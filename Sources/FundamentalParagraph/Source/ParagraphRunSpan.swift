import FundamentalDocument

package struct ParagraphRunSpan: Sendable
{
    package let index: Int
    package let range: Range<Int>
    package let attributes: SemanticRunAttributes
    package let language: SemanticLanguageIdentifier
}
