package enum WordScopeFailure: Error, Equatable, Sendable
{
    case nativeSourceChanged
    case invalidQuery(Range<Int>)
}
