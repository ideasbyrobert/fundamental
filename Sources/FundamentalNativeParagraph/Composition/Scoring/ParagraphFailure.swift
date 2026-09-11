package enum ParagraphFailure: Error, Equatable, Sendable
{
    case invalidWidth
    case missingFont
    case mutableStyle
    case changedSource
    case invalidGap
    case scoreOverflow
    case noFeasibleLayout(Range<Int>)
    case changedMeasurement
    case invalidPredecessor
}
