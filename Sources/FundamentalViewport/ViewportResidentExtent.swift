import FundamentalLayout

struct ViewportResidentExtent: Equatable, Sendable
{
    let residence: ViewportResidence
    let extent: LayoutPlacedFragmentExtent

    var canAnchor: Bool
    {
        extent.canAnchor
    }
}
