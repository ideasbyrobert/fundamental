package struct PatternResult: Equatable, Sendable
{
    package let identity: String
    package let word: String
    package let boundaries: [Int]
    package let basis: PatternBasis
    package let match: PatternMatch
}
