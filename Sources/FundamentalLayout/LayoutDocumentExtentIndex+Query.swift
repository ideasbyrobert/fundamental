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
            let entry = popHighestPriority(
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
                push(
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

    private static func push(
        _ entry: (node: Int, lower: Int, upper: Int),
        into heap: inout [(node: Int, lower: Int, upper: Int)],
        maximumY: [Double],
        maximumYPaintOrder: [Int]
    )
    {
        heap.append(entry)
        var child = heap.count - 1
        while child > 0
        {
            let parent = (child - 1) / 2
            guard isHigherPriority(
                heap[child],
                than: heap[parent],
                maximumY: maximumY,
                maximumYPaintOrder: maximumYPaintOrder
            )
            else
            {
                return
            }
            heap.swapAt(child, parent)
            child = parent
        }
    }

    private static func popHighestPriority(
        from heap: inout [(node: Int, lower: Int, upper: Int)],
        maximumY: [Double],
        maximumYPaintOrder: [Int]
    ) -> (node: Int, lower: Int, upper: Int)
    {
        let result = heap[0]
        let last = heap.removeLast()
        guard !heap.isEmpty
        else
        {
            return result
        }
        heap[0] = last
        var parent = 0
        while true
        {
            let left = parent * 2 + 1
            guard left < heap.count
            else
            {
                return result
            }
            let right = left + 1
            var child = left
            if right < heap.count,
               isHigherPriority(
                   heap[right],
                   than: heap[left],
                   maximumY: maximumY,
                   maximumYPaintOrder: maximumYPaintOrder
               )
            {
                child = right
            }
            guard isHigherPriority(
                heap[child],
                than: heap[parent],
                maximumY: maximumY,
                maximumYPaintOrder: maximumYPaintOrder
            )
            else
            {
                return result
            }
            heap.swapAt(parent, child)
            parent = child
        }
    }

    private static func isHigherPriority(
        _ first: (node: Int, lower: Int, upper: Int),
        than second: (node: Int, lower: Int, upper: Int),
        maximumY: [Double],
        maximumYPaintOrder: [Int]
    ) -> Bool
    {
        if maximumY[first.node] != maximumY[second.node]
        {
            return maximumY[first.node] > maximumY[second.node]
        }
        return maximumYPaintOrder[first.node]
            < maximumYPaintOrder[second.node]
    }
}
