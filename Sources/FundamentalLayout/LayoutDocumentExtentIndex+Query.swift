extension LayoutDocumentExtentIndex
{
    func extents(
        intersecting bounds: LayoutRectangle,
        limit: Int,
        direction: LayoutFragmentQueryDirection = .ascendingMinimumY
    ) -> LayoutDocumentExtentQuery
    {
        queryDiagnostics(
            intersecting: bounds,
            limit: limit,
            direction: direction
        ).query
    }

    func queryDiagnostics(
        intersecting bounds: LayoutRectangle,
        limit: Int,
        direction: LayoutFragmentQueryDirection = .ascendingMinimumY
    ) -> LayoutDocumentExtentQueryDiagnostics
    {
        precondition(limit > 0)
        guard bounds.size.width > 0,
              bounds.size.height > 0
        else
        {
            return LayoutDocumentExtentQueryDiagnostics(
                query: LayoutDocumentExtentQuery(
                    extents: [],
                    hasMore: false
                ),
                examinedExtentCount: 0
            )
        }
        var matches: [LayoutPlacedFragmentExtent] = []
        var hasMore = false
        var examinedExtentCount = 0
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
                extents: extents,
                maximumY: spatialMaximumY,
                matches: &matches,
                hasMore: &hasMore,
                examinedExtentCount: &examinedExtentCount
            )
        case .descendingMaximumY:
            Self.collectDescending(
                bounds: bounds,
                limit: limit,
                order: spatialOrder,
                extents: extents,
                maximumY: spatialMaximumY,
                maximumYPaintOrder: spatialMaximumYPaintOrder,
                matches: &matches,
                hasMore: &hasMore,
                examinedExtentCount: &examinedExtentCount
            )
        }
        return LayoutDocumentExtentQueryDiagnostics(
            query: LayoutDocumentExtentQuery(
                extents: matches,
                hasMore: hasMore
            ),
            examinedExtentCount: examinedExtentCount
        )
    }

    private static func collectAscending(
        node: Int,
        lower: Int,
        upper: Int,
        bounds: LayoutRectangle,
        limit: Int,
        order: [Int],
        extents: [LayoutPlacedFragmentExtent],
        maximumY: [Double],
        matches: inout [LayoutPlacedFragmentExtent],
        hasMore: inout Bool,
        examinedExtentCount: inout Int
    )
    {
        guard !hasMore,
              maximumY[node] > bounds.minY,
              extents[order[lower]].frame.minY < bounds.maxY
        else
        {
            return
        }
        if lower + 1 == upper
        {
            examinedExtentCount += 1
            let extent = extents[order[lower]]
            guard extent.frame.intersects(bounds)
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
                matches.append(extent)
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
                extents: extents,
                maximumY: maximumY,
                matches: &matches,
                hasMore: &hasMore,
                examinedExtentCount: &examinedExtentCount
            )
        }
    }

    private static func collectDescending(
        bounds: LayoutRectangle,
        limit: Int,
        order: [Int],
        extents: [LayoutPlacedFragmentExtent],
        maximumY: [Double],
        maximumYPaintOrder: [Int],
        matches: inout [LayoutPlacedFragmentExtent],
        hasMore: inout Bool,
        examinedExtentCount: inout Int
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
                extents: extents,
                maximumY: maximumY
            )
            else
            {
                continue
            }
            if entry.lower + 1 == entry.upper
            {
                examinedExtentCount += 1
                let extent = extents[order[entry.lower]]
                guard extent.frame.intersects(bounds)
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
                    matches.append(extent)
                }
                continue
            }
            let middle = entry.lower + (entry.upper - entry.lower) / 2
            let left = entry.node * 2 + 1
            for branch in [
                (left, entry.lower, middle),
                (left + 1, middle, entry.upper)
            ]
            where isCandidate(
                branch,
                bounds: bounds,
                order: order,
                extents: extents,
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
        extents: [LayoutPlacedFragmentExtent],
        maximumY: [Double]
    ) -> Bool
    {
        maximumY[entry.node] > bounds.minY
            && extents[order[entry.lower]].frame.minY < bounds.maxY
    }
}
