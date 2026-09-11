package enum ExplicitBreakRefusal: Equatable, Sendable
{
    case sourceScope
    case unsupportedLanguage(String)
    case notBreakMark
    case protectedGroup([SourceHyphenationMark])
    case graphemeBoundary
    case nonAlphabeticContext
    case ambiguousOwner
}
