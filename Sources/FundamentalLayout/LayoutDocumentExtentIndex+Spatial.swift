extension LayoutDocumentExtentIndex
{
    static func spatialIndex(
        _ extents: [LayoutPlacedFragmentExtent]
    ) -> (
        order: [Int],
        maximumY: [Double],
        maximumYPaintOrder: [Int]
    )?
    {
        let size = extents.count.multipliedReportingOverflow(by: 4)
        guard !extents.isEmpty,
              !size.overflow
        else
        {
            return nil
        }
        let order = extents.indices.sorted
        {
            let first = extents[$0]
            let second = extents[$1]
            if first.frame.minY == second.frame.minY
            {
                return $0 < $1
            }
            return first.frame.minY < second.frame.minY
        }
        var maximumY = [Double](
            repeating: 0,
            count: size.partialValue
        )
        var maximumYPaintOrder = [Int](
            repeating: 0,
            count: size.partialValue
        )
        buildSpatialIndex(
            node: 0,
            lower: 0,
            upper: order.count,
            order: order,
            extents: extents,
            maximumY: &maximumY,
            maximumYPaintOrder: &maximumYPaintOrder
        )
        return (order, maximumY, maximumYPaintOrder)
    }

    private static func buildSpatialIndex(
        node: Int,
        lower: Int,
        upper: Int,
        order: [Int],
        extents: [LayoutPlacedFragmentExtent],
        maximumY: inout [Double],
        maximumYPaintOrder: inout [Int]
    )
    {
        if lower + 1 == upper
        {
            maximumY[node] = extents[order[lower]].frame.maxY
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
            extents: extents,
            maximumY: &maximumY,
            maximumYPaintOrder: &maximumYPaintOrder
        )
        buildSpatialIndex(
            node: right,
            lower: middle,
            upper: upper,
            order: order,
            extents: extents,
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
}
