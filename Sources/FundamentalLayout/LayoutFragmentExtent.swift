import FundamentalProjection

struct LayoutFragmentExtent: Equatable, Sendable
{
    let source: ProjectedBlockSource
    let anchor: LayoutFragmentAnchor
    let frame: LayoutRectangle
    let content: LayoutFragmentExtentContent

    init(
        source: ProjectedBlockSource,
        anchor: LayoutFragmentAnchor,
        frame: LayoutRectangle,
        content: LayoutFragmentExtentContent
    )
    {
        self.source = source
        self.anchor = anchor
        self.frame = frame
        self.content = content
    }
}
