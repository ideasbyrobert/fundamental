import FundamentalParagraph
package enum HyphenatedGlyphSource: Equatable, Sendable
{
    case source(ExplicitDisplayAtom)
    case generated(AutomaticHyphenInk)
}
