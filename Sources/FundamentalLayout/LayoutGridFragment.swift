import FundamentalProjection

package struct LayoutGridFragment: Equatable, Sendable
{
    package let anchor: LayoutFragmentAnchor
    package let source: ProjectedBlockSource
    package let frame: LayoutRectangle
    package let content: LayoutGridFragmentContent
}
