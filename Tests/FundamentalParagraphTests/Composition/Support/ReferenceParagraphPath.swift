@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
struct ReferenceParagraphPath
{
    let nodes: [Int]
    let score: ParagraphScore
    let fitness: Int

    var rank: (Int, Int, Double)
    {
        (score.emergency, score.ragged, score.demerits)
    }
}
