import FundamentalViewport

extension ViewportRasterizer
{
    static func admitsContent(
        _ resident: ResidentLayoutFragment, residentID: RasterResidentID,
        frame: RasterRectangle, targetBounds: RasterRectangle,
        budget: inout RasterAdmissionBudget
    ) -> Bool
    {
        switch resident.fragment
        {
        case let .lines(fragment):
            guard let role = role(fragment.role)
            else
            {
                return false
            }
            return admits(
                fragment.line, residentID: residentID, role: role,
                targetBounds: targetBounds, budget: &budget
            )
        case let .grid(fragment):
            switch fragment.content
            {
            case let .captionLine(line):
                return admits(
                    line, residentID: residentID, role: .caption,
                    targetBounds: targetBounds, budget: &budget
                )
            case let .cellLine(line):
                return admits(
                    line.line, residentID: residentID, role: role(line),
                    targetBounds: targetBounds, budget: &budget
                )
            case .region:
                return consumeFill(
                    frame, targetBounds: targetBounds, budget: &budget
                )
            case let .rowTrack(track):
                return track.scope != .header || consumeFill(
                    frame, targetBounds: targetBounds, budget: &budget
                )
            case .cell, .columnTrack:
                return true
            case .rule:
                return false
            }
        }
    }
}
