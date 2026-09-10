import FundamentalViewport

extension ViewportRasterizer
{
    static func admits(
        _ resident: ResidentLayoutFragment,
        targetBounds: RasterRectangle, budget: inout RasterAdmissionBudget
    ) -> Bool
    {
        guard let frame = rectangle(
            x: resident.fragment.frame.minX,
            y: resident.fragment.frame.minY,
            width: resident.fragment.frame.size.width,
            height: resident.fragment.frame.size.height
        )
        else
        {
            return false
        }
        if case let .grid(fragment) = resident.fragment,
           case .rule = fragment.content
        {
            return consumeFill(
                frame, targetBounds: targetBounds, budget: &budget
            )
        }
        guard budget.consumeInteractionRegion()
        else
        {
            return false
        }
        let anchor = resident.fragment.anchor
        let residentID = RasterResidentID(
            blockID: anchor.blockID, blockOrdinal: anchor.blockOrdinal,
            fragmentOrdinal: anchor.fragmentOrdinal
        )
        return admitsContent(
            resident, residentID: residentID, frame: frame,
            targetBounds: targetBounds, budget: &budget
        )
    }
}
