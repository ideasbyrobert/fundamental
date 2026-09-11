package enum WordScopeResolution: Equatable, Sendable
{
    case resolved(ResolvedWordScope)
    case refused(Range<Int>, [WordScopeRefusal])

    package var range: Range<Int>
    {
        switch self
        {
        case let .resolved(scope):
            scope.range
        case let .refused(range, _):
            range
        }
    }
}
