package enum NativeSpacingFailure: Error, Equatable, Sendable
{
    case invalidPlan
    case changedMetrics
    case ambiguousGap
    case unsupportedDirection
    case unsupportedMatrix
    case unsupportedDecoration
    case invalidBaseline
    case missingFont
}
