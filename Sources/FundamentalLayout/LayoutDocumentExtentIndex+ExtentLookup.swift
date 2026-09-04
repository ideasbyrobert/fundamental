extension LayoutDocumentExtentIndex
{
    func position(
        of candidate: LayoutPlacedFragmentExtent
    ) -> Int?
    {
        var lower = 0
        var upper = extents.count
        while lower < upper
        {
            let middle = lower + (upper - lower) / 2
            let anchor = extents[middle].anchor
            if Self.precedes(anchor, candidate.anchor)
            {
                lower = middle + 1
            }
            else
            {
                upper = middle
            }
        }
        guard lower < extents.count,
              extents[lower] == candidate
        else
        {
            return nil
        }
        return lower
    }

    func completeExtentRange(
        containing extent: LayoutPlacedFragmentExtent
    ) -> Range<Int>?
    {
        guard let position = position(of: extent),
              extent.anchor.fragmentOrdinal >= 0,
              position >= extent.anchor.fragmentOrdinal
        else
        {
            return nil
        }
        let lower = position - extent.anchor.fragmentOrdinal
        let first = extents[lower]
        guard first.anchor.blockID == extent.anchor.blockID,
              first.anchor.blockOrdinal == extent.anchor.blockOrdinal,
              first.anchor.fragmentOrdinal == 0,
              first.localExtent.frame.minX == 0,
              first.localExtent.frame.minY == 0
        else
        {
            return nil
        }
        var upper = lower
        while upper < extents.count
        {
            let candidate = extents[upper]
            guard candidate.anchor.blockID == first.anchor.blockID,
                  candidate.anchor.blockOrdinal
                    == first.anchor.blockOrdinal
            else
            {
                break
            }
            guard candidate.anchor.fragmentOrdinal == upper - lower
            else
            {
                return nil
            }
            upper += 1
        }
        return lower ..< upper
    }

    private static func precedes(
        _ first: LayoutFragmentAnchor,
        _ second: LayoutFragmentAnchor
    ) -> Bool
    {
        if first.blockOrdinal != second.blockOrdinal
        {
            return first.blockOrdinal < second.blockOrdinal
        }
        return first.fragmentOrdinal < second.fragmentOrdinal
    }
}
