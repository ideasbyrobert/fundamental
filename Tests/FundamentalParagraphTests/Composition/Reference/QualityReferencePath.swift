@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
struct QualityReferencePath
{
    let nodes: [Int]
    let emergency: Int
    let ragged: Int
    let demerits: Double
    let fitness: Int

    static let empty = Self(
        nodes: [], emergency: 0, ragged: 0, demerits: 0, fitness: 1
    )

    var rank: (Int, Double)
    {
        (emergency, demerits)
    }

    var score: QualityScore
    {
        QualityScore(emergency: emergency, demerits: demerits)
    }
}
