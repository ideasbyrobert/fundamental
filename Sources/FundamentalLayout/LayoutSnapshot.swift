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
        Self.buildSpatialIndex(
            node: 0,
            lower: 0,
            upper: spatialOrder.count,
            order: spatialOrder,
            fragments: fragments,
            maximumY: &maximumY
        )
        spatialMaximumY = maximumY
    }

    package func fragments(
        intersecting bounds: LayoutRectangle,
        limit: Int
    ) -> LayoutFragmentQuery
    {
        queryDiagnostics(
            intersecting: bounds,
            limit: limit
        ).query
    }

    func queryDiagnostics(
        intersecting bounds: LayoutRectangle,
        limit: Int
    ) -> LayoutFragmentQueryDiagnostics
    {
        precondition(limit > 0)
        var matches: [LayoutFragment] = []
        var hasMore = false
        var examinedFragmentCount = 0
        Self.collect(
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
        maximumY: inout [Double]
    )
    {
        if lower + 1 == upper
        {
            maximumY[node] = fragments[order[lower]].frame.maxY
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
            maximumY: &maximumY
        )
        buildSpatialIndex(
            node: right,
            lower: middle,
            upper: upper,
            order: order,
            fragments: fragments,
            maximumY: &maximumY
        )
        maximumY[node] = max(maximumY[left], maximumY[right])
    }

    private static func collect(
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
        collect(
            node: left,
            lower: lower,
            upper: middle,
            bounds: bounds,
            limit: limit,
            order: order,
            fragments: fragments,
            maximumY: maximumY,
            matches: &matches,
            hasMore: &hasMore,
            examinedFragmentCount: &examinedFragmentCount
        )
        collect(
            node: left + 1,
            lower: middle,
            upper: upper,
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
