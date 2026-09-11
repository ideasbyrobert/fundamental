import FundamentalParagraph
package enum HyphenatedLineEnd: Sendable
{
    case unbroken
    case explicit(ExplicitBreakSelection)
    case automatic(AutomaticSelection)
}
