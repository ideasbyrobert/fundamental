package enum HyphenationFailure: Error, Equatable, Sendable
{
    case invalidRange(Range<Int>)
    case incompatibleNormalization
    case unmappedSource(Int)
    case unmappedLookup(Int)
}
