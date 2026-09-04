import FundamentalLayout

extension ViewportResidentExtentWindow
{
    static func admitResidents(
        indexed: LayoutIndexedProjection,
        request: ViewportRequest,
        precedingBounds: LayoutRectangle,
        followingBounds: LayoutRectangle
    ) -> (
        visible: [ViewportResidentExtent],
        overscan: [ViewportResidentExtent],
        residents: [ViewportResidentExtent],
        query: ViewportQueryDiagnostics
    )?
    {
        let limit = request.maximumResidentCount
        let visibleDiagnostics = indexed.queryDiagnostics(
            intersecting: request.visibleBounds,
            limit: limit
        )
        guard !visibleDiagnostics.query.hasMore
        else
        {
            return nil
        }
        let visible = visibleDiagnostics.query.extents.map
        {
            ViewportResidentExtent(
                residence: .visible,
                extent: $0
            )
        }
        let anchors = Set(visible.map(\.extent.anchor))
        let preceding = overscan(
            indexed: indexed,
            bounds: precedingBounds,
            extent: request.precedingOverscanExtent,
            limit: limit,
            direction: .descendingMaximumY,
            residence: .overscan(.preceding),
            excluding: anchors
        )
        let following = overscan(
            indexed: indexed,
            bounds: followingBounds,
            extent: request.followingOverscanExtent,
            limit: limit,
            direction: .ascendingMinimumY,
            residence: .overscan(.following),
            excluding: anchors
        )
        let capacity = limit - visible.count
        let overscan = (preceding.residents + following.residents).sorted
        {
            isNearer($0, than: $1, request: request)
        }.prefix(capacity)
        let admittedOverscan = Array(overscan)
        let residents = (visible + admittedOverscan).sorted(
            by: isPaintOrdered
        )
        return (
            visible,
            admittedOverscan,
            residents,
            ViewportQueryDiagnostics(
                visibleFragmentsExamined:
                    visibleDiagnostics.examinedExtentCount,
                precedingFragmentsExamined: preceding.examined,
                followingFragmentsExamined: following.examined
            )
        )
    }

    private static func overscan(
        indexed: LayoutIndexedProjection,
        bounds: LayoutRectangle,
        extent: Double,
        limit: Int,
        direction: LayoutFragmentQueryDirection,
        residence: ViewportResidence,
        excluding anchors: Set<LayoutFragmentAnchor>
    ) -> (residents: [ViewportResidentExtent], examined: Int)
    {
        guard extent > 0
        else
        {
            return ([], 0)
        }
        let diagnostics = indexed.queryDiagnostics(
            intersecting: bounds,
            limit: limit,
            direction: direction
        )
        let candidates = diagnostics.query.extents.filter
        {
            !anchors.contains($0.anchor)
        }
        let residents: [ViewportResidentExtent] = candidates.map
        {
            ViewportResidentExtent(
                residence: residence,
                extent: $0
            )
        }
        return (residents, diagnostics.examinedExtentCount)
    }
}
