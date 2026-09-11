struct QualityState
{
    let score: QualityScore
    let predecessor: ParagraphPredecessor
}

enum QualityReachability
{
    case unavailable
    case reached(QualityState)
}
