import FundamentalProjection

package struct LayoutSourceSlice: Equatable, Sendable
{
    package let source: ProjectedTextSource
    package let range: Range<Int>
    package let text: String
}
