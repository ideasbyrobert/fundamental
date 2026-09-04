package struct LayoutFragmentMaterialization: Equatable, Sendable
{
    package let lineage: LayoutLineage
    package let documentSize: LayoutSize
    package let fragments: [LayoutMaterializedFragment]

    init?(
        _ admission: LayoutMaterializationAdmissionToken,
        index: LayoutDocumentExtentIndex,
        selection: LayoutFragmentExtentSelection,
        fragments: [LayoutMaterializedFragment]
    )
    {
        guard selection.lineage == index.lineage,
              index.selection(
                  expectedLineage: index.lineage,
                  extents: selection.extents
              ) == selection,
              fragments.map(\.extent) == selection.extents,
              !fragments.isEmpty,
              Set(fragments.map(\.fragment.anchor)).count
                == fragments.count,
              fragments.allSatisfy(
                  { Self.fits($0.extent.frame, in: index.size) }
              ),
              zip(fragments, fragments.dropFirst()).allSatisfy(
                  { Self.precedes($0.0.fragment, $0.1.fragment) }
              )
        else
        {
            return nil
        }
        lineage = index.lineage
        documentSize = index.size
        self.fragments = fragments
    }

    private static func fits(
        _ frame: LayoutRectangle,
        in size: LayoutSize
    ) -> Bool
    {
        frame.minX >= 0
            && frame.minY >= 0
            && frame.maxX <= size.width
            && frame.maxY <= size.height
    }

    private static func precedes(
        _ first: LayoutFragment,
        _ second: LayoutFragment
    ) -> Bool
    {
        if first.anchor.blockOrdinal != second.anchor.blockOrdinal
        {
            return first.anchor.blockOrdinal
                < second.anchor.blockOrdinal
        }
        return first.anchor.fragmentOrdinal
            < second.anchor.fragmentOrdinal
    }
}
