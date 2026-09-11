package enum WordScopeFailure: Error, Equatable, Sendable
{
    case nativeSourceChanged
    case invalidDefaultLanguage(String)
    case invalidQuery(Range<Int>)
}
