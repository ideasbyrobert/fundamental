package struct QualityPath: Sendable
{
    package let nodes: [Int]
    package let score: QualityScore
    package let statesRetained: Int
    package let transitions: Int
}
