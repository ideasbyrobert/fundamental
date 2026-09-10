package struct WrappingSourceLine: Equatable, Hashable, Sendable
{
    package let contentRange: Range<Int>
    package let endingRange: Range<Int>
    package let ending: WrappingLineEnding?

    package var range: Range<Int>
    {
        contentRange.lowerBound ..< endingRange.upperBound
    }
}
