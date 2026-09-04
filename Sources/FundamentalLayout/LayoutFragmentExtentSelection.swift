struct LayoutFragmentExtentSelection: Equatable, Sendable
{
    let lineage: LayoutLineage
    let extents: [LayoutPlacedFragmentExtent]

    fileprivate init(
        lineage: LayoutLineage,
        extents: [LayoutPlacedFragmentExtent]
    )
    {
        self.lineage = lineage
        self.extents = extents
    }
}

extension LayoutDocumentExtentIndex
{
    func selection(
        expectedLineage: LayoutLineage,
        extents candidates: [LayoutPlacedFragmentExtent]
    ) -> LayoutFragmentExtentSelection?
    {
        guard expectedLineage == lineage,
              !candidates.isEmpty
        else
        {
            return nil
        }
        var anchors = Set<LayoutFragmentAnchor>()
        var positions: [Int] = []
        for candidate in candidates
        {
            guard anchors.insert(candidate.anchor).inserted,
                  let position = position(of: candidate)
            else
            {
                return nil
            }
            positions.append(position)
        }
        positions.sort()
        return LayoutFragmentExtentSelection(
            lineage: lineage,
            extents: positions.map { extents[$0] }
        )
    }
}
