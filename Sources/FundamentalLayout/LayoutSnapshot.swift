package struct LayoutSnapshot: Equatable, Sendable
{
    package let lineage: LayoutLineage
    package let size: LayoutSize
    package let firstFragment: LayoutFragment
    package let remainingFragments: [LayoutFragment]
    package let grids: [LayoutGrid]
    private let spatialFragments: [LayoutFragment]
    private let spatialOrder: [Int]
    private let spatialMaximumY: [Double]
    private let spatialMaximumYPaintOrder: [Int]

    package var fragments: [LayoutFragment]
    {
        [firstFragment] + remainingFragments
    }

    init(
        lineage: LayoutLineage,
        size: LayoutSize,
        firstFragment: LayoutFragment,
        remainingFragments: [LayoutFragment],
        grids: [LayoutGrid]
    )
    {
        self.lineage = lineage
        self.size = size
        self.firstFragment = firstFragment
        self.remainingFragments = remainingFragments
        self.grids = grids
        let fragments = [firstFragment] + remainingFragments
        spatialFragments = fragments
        spatialOrder = fragments.indices.sorted
        {
            let first = fragments[$0]
            let second = fragments[$1]
            if first.frame.minY == second.frame.minY
            {
                return $0 < $1
            }
            return first.frame.minY < second.frame.minY
        }
        var maximumY = [Double](
            repeating: 0,
            count: spatialOrder.count * 4
        )
        var maximumYPaintOrder = [Int](
            repeating: 0,
            count: spatialOrder.count * 4
        )
        Self.buildSpatialIndex(
            node: 0,
            lower: 0,
            upper: spatialOrder.count,
            order: spatialOrder,
            fragments: fragments,
            maximumY: &maximumY,
            maximumYPaintOrder: &maximumYPaintOrder
        )
        spatialMaximumY = maximumY
        spatialMaximumYPaintOrder = maximumYPaintOrder
    }

    package func fragments(
        intersecting bounds: LayoutRectangle,
        limit: Int,
        direction: LayoutFragmentQueryDirection = .ascendingMinimumY
    ) -> LayoutFragmentQuery
    {
        queryDiagnostics(
            intersecting: bounds,
            limit: limit,
            direction: direction
        ).query
    }

    package func queryDiagnostics(
        intersecting bounds: LayoutRectangle,
        limit: Int,
        direction: LayoutFragmentQueryDirection = .ascendingMinimumY
    ) -> LayoutFragmentQueryDiagnostics
    {
        precondition(limit > 0)
        guard bounds.size.width > 0,
              bounds.size.height > 0
        else
        {
            return LayoutFragmentQueryDiagnostics(
                query: LayoutFragmentQuery(
                    fragments: [],
                    hasMore: false
                ),
                examinedFragmentCount: 0
            )
        }
        var matches: [LayoutFragment] = []
        var hasMore = false
        var examinedFragmentCount = 0
        switch direction
        {
        case .ascendingMinimumY:
            Self.collectAscending(
                node: 0,
                lower: 0,
                upper: spatialOrder.count,
                bounds: bounds,
                limit: limit,
                order: spatialOrder,
                fragments: spatialFragments,
                maximumY: spatialMaximumY,
                matches: &matches,
                hasMore: &hasMore,
                examinedFragmentCount: &examinedFragmentCount
            )
        case .descendingMaximumY:
            Self.collectDescendingMaximumY(
                bounds: bounds,
                limit: limit,
                order: spatialOrder,
                fragments: spatialFragments,
                maximumY: spatialMaximumY,
                maximumYPaintOrder: spatialMaximumYPaintOrder,
                matches: &matches,
                hasMore: &hasMore,
                examinedFragmentCount: &examinedFragmentCount
            )
        }
        return LayoutFragmentQueryDiagnostics(
            query: LayoutFragmentQuery(
                fragments: matches,
                hasMore: hasMore
            ),
            examinedFragmentCount: examinedFragmentCount
        )
    }

    private static func buildSpatialIndex(
        node: Int,
        lower: Int,
        upper: Int,
        order: [Int],
        fragments: [LayoutFragment],
        maximumY: inout [Double],
        maximumYPaintOrder: inout [Int]
    )
    {
        if lower + 1 == upper
        {
            maximumY[node] = fragments[order[lower]].frame.maxY
            maximumYPaintOrder[node] = order[lower]
            return
        }
        let middle = lower + (upper - lower) / 2
        let left = node * 2 + 1
        let right = left + 1
        buildSpatialIndex(
            node: left,
            lower: lower,
            upper: middle,
            order: order,
            fragments: fragments,
            maximumY: &maximumY,
            maximumYPaintOrder: &maximumYPaintOrder
        )
        buildSpatialIndex(
            node: right,
            lower: middle,
            upper: upper,
            order: order,
            fragments: fragments,
            maximumY: &maximumY,
            maximumYPaintOrder: &maximumYPaintOrder
        )
        maximumY[node] = max(maximumY[left], maximumY[right])
        if maximumY[left] > maximumY[right]
        {
            maximumYPaintOrder[node] = maximumYPaintOrder[left]
        }
        else if maximumY[right] > maximumY[left]
        {
            maximumYPaintOrder[node] = maximumYPaintOrder[right]
        }
        else
        {
            maximumYPaintOrder[node] = min(
                maximumYPaintOrder[left],
                maximumYPaintOrder[right]
            )
        }
    }

    private static func collectAscending(
        node: Int,
        lower: Int,
        upper: Int,
        bounds: LayoutRectangle,
        limit: Int,
        order: [Int],
        fragments: [LayoutFragment],
        maximumY: [Double],
        matches: inout [LayoutFragment],
        hasMore: inout Bool,
        examinedFragmentCount: inout Int
    )
    {
        guard !hasMore,
              maximumY[node] > bounds.minY,
              fragments[order[lower]].frame.minY < bounds.maxY
        else
        {
            return
        }
        if lower + 1 == upper
        {
            examinedFragmentCount += 1
            let fragment = fragments[order[lower]]
            guard fragment.frame.intersects(bounds)
            else
            {
                return
            }
            if matches.count == limit
            {
                hasMore = true
            }
            else
            {
                matches.append(fragment)
            }
            return
        }
        let middle = lower + (upper - lower) / 2
        let left = node * 2 + 1
        for branch in [
            (left, lower, middle),
            (left + 1, middle, upper)
        ]
        {
            collectAscending(
                node: branch.0,
                lower: branch.1,
                upper: branch.2,
                bounds: bounds,
                limit: limit,
                order: order,
                fragments: fragments,
                maximumY: maximumY,
                matches: &matches,
                hasMore: &hasMore,
                examinedFragmentCount: &examinedFragmentCount
            )
        }
    }

    private static func collectDescendingMaximumY(
        bounds: LayoutRectangle,
        limit: Int,
        order: [Int],
        fragments: [LayoutFragment],
        maximumY: [Double],
        maximumYPaintOrder: [Int],
        matches: inout [LayoutFragment],
        hasMore: inout Bool,
        examinedFragmentCount: inout Int
    )
    {
        var heap = [(node: 0, lower: 0, upper: order.count)]
        while !heap.isEmpty && !hasMore
        {
            let entry = LayoutQueryHeap.popHighestPriority(
                from: &heap,
                maximumY: maximumY,
                maximumYPaintOrder: maximumYPaintOrder
            )
            guard isCandidate(
                entry,
                bounds: bounds,
                order: order,
                fragments: fragments,
                maximumY: maximumY
            )
            else
            {
                continue
            }
            if entry.lower + 1 == entry.upper
            {
                examinedFragmentCount += 1
                let fragment = fragments[order[entry.lower]]
                guard fragment.frame.intersects(bounds)
                else
                {
                    continue
                }
                if matches.count == limit
                {
                    hasMore = true
                }
                else
                {
                    matches.append(fragment)
                }
                continue
            }
            let middle = entry.lower
                + (entry.upper - entry.lower) / 2
            let left = entry.node * 2 + 1
            for branch in [
                (left, entry.lower, middle),
                (left + 1, middle, entry.upper)
            ]
            where isCandidate(
                branch,
                bounds: bounds,
                order: order,
                fragments: fragments,
                maximumY: maximumY
            )
            {
                LayoutQueryHeap.push(
                    branch,
                    into: &heap,
                    maximumY: maximumY,
                    maximumYPaintOrder: maximumYPaintOrder
                )
            }
        }
    }

    private static func isCandidate(
        _ entry: (node: Int, lower: Int, upper: Int),
        bounds: LayoutRectangle,
        order: [Int],
        fragments: [LayoutFragment],
        maximumY: [Double]
    ) -> Bool
    {
        maximumY[entry.node] > bounds.minY
            && fragments[order[entry.lower]].frame.minY < bounds.maxY
    }
}
