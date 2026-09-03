import FundamentalLayout

package struct ViewportSnapshot: Equatable, Sendable
{
    package let lineage: ViewportLineage
    package let visibleBounds: LayoutRectangle
    package let documentSize: LayoutSize
    package let sourceAnchor: ViewportSourceAnchor
    package let residents: ViewportResidents

    package init?(
        _ layout: LayoutSnapshot,
        request: ViewportRequest
    )
    {
        var queryDiagnostics = ViewportQueryDiagnostics.zero
        guard let snapshot = Self(
            layout,
            request: request,
            queryDiagnostics: &queryDiagnostics
        )
        else
        {
            return nil
        }
        self = snapshot
    }

    static func admissionDiagnostics(
        _ layout: LayoutSnapshot,
        request: ViewportRequest
    ) -> ViewportAdmissionDiagnostics?
    {
        var queryDiagnostics = ViewportQueryDiagnostics.zero
        guard let snapshot = Self(
            layout,
            request: request,
            queryDiagnostics: &queryDiagnostics
        )
        else
        {
            return nil
        }
        return ViewportAdmissionDiagnostics(
            snapshot: snapshot,
            query: queryDiagnostics
        )
    }

    private init?(
        _ layout: LayoutSnapshot,
        request: ViewportRequest,
        queryDiagnostics: inout ViewportQueryDiagnostics
    )
    {
        guard layout.lineage == request.expectedLayoutLineage,
              request.visibleBounds.minX == 0,
              request.visibleBounds.size.width == layout.size.width,
              let precedingBounds = Self.precedingBounds(request),
              let followingBounds = Self.followingBounds(request)
        else
        {
            return nil
        }
        let limit = request.maximumResidentCount
        let visibleDiagnostics = layout.queryDiagnostics(
            intersecting: request.visibleBounds,
            limit: limit
        )
        let visibleQuery = visibleDiagnostics.query
        guard !visibleQuery.hasMore
        else
        {
            return nil
        }
        let visible = visibleQuery.fragments.map
        {
            ResidentLayoutFragment(
                residence: .visible,
                fragment: $0
            )
        }
        let visibleAnchors = Set(visible.map(\.fragment.anchor))
        let precedingFragments: [LayoutFragment]
        let precedingExamined: Int
        if request.precedingOverscanExtent == 0
        {
            precedingFragments = []
            precedingExamined = 0
        }
        else
        {
            let diagnostics = layout.queryDiagnostics(
                intersecting: precedingBounds,
                limit: limit,
                direction: .descendingMaximumY
            )
            precedingFragments = diagnostics.query.fragments
            precedingExamined = diagnostics.examinedFragmentCount
        }
        let followingFragments: [LayoutFragment]
        let followingExamined: Int
        if request.followingOverscanExtent == 0
        {
            followingFragments = []
            followingExamined = 0
        }
        else
        {
            let diagnostics = layout.queryDiagnostics(
                intersecting: followingBounds,
                limit: limit,
                direction: .ascendingMinimumY
            )
            followingFragments = diagnostics.query.fragments
            followingExamined = diagnostics.examinedFragmentCount
        }
        let preceding: [ResidentLayoutFragment]
        preceding = precedingFragments.compactMap
        {
            guard !visibleAnchors.contains($0.anchor)
            else
            {
                return nil
            }
            return ResidentLayoutFragment(
                residence: .overscan(.preceding),
                fragment: $0
            )
        }
        let following: [ResidentLayoutFragment]
        following = followingFragments.compactMap
        {
            guard !visibleAnchors.contains($0.anchor)
            else
            {
                return nil
            }
            return ResidentLayoutFragment(
                residence: .overscan(.following),
                fragment: $0
            )
        }
        let capacity = limit - visible.count
        let overscan = (preceding + following).sorted
        {
            Self.isNearer($0, than: $1, request: request)
        }.prefix(capacity)
        let residents = (visible + Array(overscan)).sorted(
            by: Self.isPaintOrdered
        )
        guard let first = residents.first,
              let anchorResident = residents.first(where:
              {
                  $0.residence == .visible && $0.canAnchor
              }) ?? overscan.first(where: \.canAnchor)
        else
        {
            return nil
        }
        self.lineage = ViewportLineage(
            layout: layout.lineage,
            generation: request.generation,
            specification: request.specification
        )
        visibleBounds = request.visibleBounds
        documentSize = layout.size
        sourceAnchor = ViewportSourceAnchor(
            fragment: anchorResident.fragment.anchor,
            relativeX: anchorResident.fragment.frame.minX
                - request.visibleBounds.minX,
            relativeY: anchorResident.fragment.frame.minY
                - request.visibleBounds.minY
        )
        self.residents = ViewportResidents(
            first: first,
            remaining: Array(residents.dropFirst())
        )
        queryDiagnostics = ViewportQueryDiagnostics(
            visibleFragmentsExamined:
                visibleDiagnostics.examinedFragmentCount,
            precedingFragmentsExamined: precedingExamined,
            followingFragmentsExamined: followingExamined
        )
    }

    private static func precedingBounds(
        _ request: ViewportRequest
    ) -> LayoutRectangle?
    {
        guard let origin = LayoutPoint(
            x: request.visibleBounds.minX,
            y: request.visibleBounds.minY
                - request.precedingOverscanExtent
        ),
              let size = LayoutSize(
                  width: request.visibleBounds.size.width,
                  height: request.precedingOverscanExtent
              )
        else
        {
            return nil
        }
        return LayoutRectangle(origin: origin, size: size)
    }

    private static func followingBounds(
        _ request: ViewportRequest
    ) -> LayoutRectangle?
    {
        guard let origin = LayoutPoint(
            x: request.visibleBounds.minX,
            y: request.visibleBounds.maxY
        ),
              let size = LayoutSize(
                  width: request.visibleBounds.size.width,
                  height: request.followingOverscanExtent
              )
        else
        {
            return nil
        }
        return LayoutRectangle(origin: origin, size: size)
    }

    private static func isNearer(
        _ first: ResidentLayoutFragment,
        than second: ResidentLayoutFragment,
        request: ViewportRequest
    ) -> Bool
    {
        let firstDistance = distance(first, request: request)
        let secondDistance = distance(second, request: request)
        if firstDistance != secondDistance
        {
            return firstDistance < secondDistance
        }
        if first.residence != second.residence
        {
            return first.residence == .overscan(.preceding)
        }
        return isPaintOrdered(first, second)
    }

    private static func distance(
        _ resident: ResidentLayoutFragment,
        request: ViewportRequest
    ) -> Double
    {
        switch resident.residence
        {
        case .visible:
            return 0
        case .overscan(.preceding):
            return max(
                0,
                request.visibleBounds.minY - resident.fragment.frame.maxY
            )
        case .overscan(.following):
            return max(
                0,
                resident.fragment.frame.minY - request.visibleBounds.maxY
            )
        }
    }

    private static func isPaintOrdered(
        _ first: ResidentLayoutFragment,
        _ second: ResidentLayoutFragment
    ) -> Bool
    {
        let firstAnchor = first.fragment.anchor
        let secondAnchor = second.fragment.anchor
        if firstAnchor.blockOrdinal != secondAnchor.blockOrdinal
        {
            return firstAnchor.blockOrdinal < secondAnchor.blockOrdinal
        }
        return firstAnchor.fragmentOrdinal < secondAnchor.fragmentOrdinal
    }
}
