package struct ExplicitHyphenOpportunity: Equatable, Sendable
{
    package let mark: SourceHyphenationMark
    package let owner: WordRunFragment
    package let ink: ExplicitHyphenInk

    package var sourceOffset: Int
    {
        mark.range.upperBound
    }
}
