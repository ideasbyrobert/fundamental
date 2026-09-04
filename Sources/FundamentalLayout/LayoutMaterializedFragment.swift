struct LayoutMaterializedFragment: Equatable, Sendable
{
    let extent: LayoutPlacedFragmentExtent
    let fragment: LayoutFragment

    init?(
        _ admission: LayoutMaterializationAdmissionToken,
        extent: LayoutPlacedFragmentExtent,
        fragment: LayoutFragment
    )
    {
        guard Self.matches(fragment, extent: extent)
        else
        {
            return nil
        }
        self.extent = extent
        self.fragment = fragment
    }

    static func matches(
        _ fragment: LayoutFragment,
        extent: LayoutPlacedFragmentExtent
    ) -> Bool
    {
        let reduced = LayoutFragmentExtent(fragment)
        return reduced.source == extent.source
            && reduced.anchor == extent.anchor
            && reduced.frame == extent.frame
            && reduced.content == extent.content
    }
}
