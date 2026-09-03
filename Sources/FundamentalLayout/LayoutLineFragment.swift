import FundamentalProjection

package struct LayoutLineFragment: Equatable, Sendable
{
    package let anchor: LayoutFragmentAnchor
    package let source: ProjectedBlockSource
    package let role: LayoutLineRole
    package let frame: LayoutRectangle
    package let line: LayoutLine
}
