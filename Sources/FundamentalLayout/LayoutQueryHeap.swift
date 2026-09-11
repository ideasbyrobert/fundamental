enum LayoutQueryHeap
{
    static func push(
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

    static func popHighestPriority(
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
