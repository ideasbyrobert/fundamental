extension LayoutIndexedProjection
{
    package var lineage: LayoutLineage
    {
        index.lineage
    }

    package var documentSize: LayoutSize
    {
        index.size
    }

    package func queryDiagnostics(
        intersecting bounds: LayoutRectangle,
        limit: Int,
        direction: LayoutFragmentQueryDirection = .ascendingMinimumY
    ) -> LayoutDocumentExtentQueryDiagnostics
    {
        index.queryDiagnostics(
            intersecting: bounds,
            limit: limit,
            direction: direction
        )
    }

    package func selection(
        extents: [LayoutPlacedFragmentExtent]
    ) -> LayoutFragmentExtentSelection?
    {
        index.selection(
            expectedLineage: index.lineage,
            extents: extents
        )
    }

    @MainActor
    package func materializationDiagnostics(
        selection: LayoutFragmentExtentSelection,
        capacity: LayoutMaterializationCapacity
    ) throws -> LayoutFragmentMaterializationDiagnostics?
    {
        try NativeTextKit2Layout().materializationDiagnostics(
            indexed: self,
            selection: selection,
            capacity: capacity
        )
    }
}
