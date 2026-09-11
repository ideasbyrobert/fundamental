import FundamentalDocument

package enum WordScopeRefusal: Equatable, Sendable
{
    case invalidBounds
    case emptyRange
    case graphemeBoundary
    case incompatibleLanguages([SemanticLanguageIdentifier])
    case inlineCode([Int])
    case hardEndings([Range<Int>])
}
