package enum ExplicitProjectionFailure: Error, Equatable, Sendable
{
    case invalidRange(Range<Int>)
    case hardEnding
    case invalidSelection(Int)
    case refusedSelection(Int)
    case foreignSelection
    case endMismatch
    case markerExcluded
}
