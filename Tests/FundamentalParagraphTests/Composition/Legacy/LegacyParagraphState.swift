@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
struct ParagraphState
{
    let score: ParagraphScore
    let predecessor: ParagraphPredecessor
}

enum ParagraphReachability
{
    case unavailable
    case reached(ParagraphState)
}
