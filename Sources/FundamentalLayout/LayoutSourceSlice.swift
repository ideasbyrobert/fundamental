import FundamentalProjection

package struct LayoutSourceSlice: Equatable, Sendable
{
    package let source: ProjectedTextSource
    package let scope: LayoutRunScope
    package let range: Range<Int>
    package let text: String

    package var scopePayloads: [String]
    {
        switch scope
        {
        case .direct:
            []
        case let .link(destination):
            [destination]
        case let .language(identifier):
            [identifier]
        case let .linkAndLanguage(link, language):
            [link, language]
        }
    }
}
