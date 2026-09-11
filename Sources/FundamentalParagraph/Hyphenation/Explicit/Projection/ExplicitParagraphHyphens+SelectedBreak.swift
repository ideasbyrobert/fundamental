extension ExplicitParagraphHyphens
{
    func selectedBreak(
        _ end: ExplicitSliceEnd, range: Range<Int>
    ) throws(ExplicitProjectionFailure) -> ExplicitSelectedBreak
    {
        switch end
        {
        case .unbroken:
            return .unbroken
        case let .opportunity(selection):
            guard selection.owner === identity
            else
            {
                throw .foreignSelection
            }
            let value = try opportunity(at: selection.index)
            guard value.sourceOffset == range.upperBound
            else
            {
                throw .endMismatch
            }
            guard range.lowerBound <= value.mark.range.lowerBound
            else
            {
                throw .markerExcluded
            }
            return .explicit(value)
        }
    }
}
