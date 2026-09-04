extension ViewportResidentExtentWindow
{
    static func isNearer(
        _ first: ViewportResidentExtent,
        than second: ViewportResidentExtent,
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

    static func distance(
        _ resident: ViewportResidentExtent,
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
                request.visibleBounds.minY - resident.extent.frame.maxY
            )
        case .overscan(.following):
            return max(
                0,
                resident.extent.frame.minY - request.visibleBounds.maxY
            )
        }
    }

    static func isPaintOrdered(
        _ first: ViewportResidentExtent,
        _ second: ViewportResidentExtent
    ) -> Bool
    {
        let firstAnchor = first.extent.anchor
        let secondAnchor = second.extent.anchor
        if firstAnchor.blockOrdinal != secondAnchor.blockOrdinal
        {
            return firstAnchor.blockOrdinal < secondAnchor.blockOrdinal
        }
        return firstAnchor.fragmentOrdinal < secondAnchor.fragmentOrdinal
    }
}
