struct LayoutMaterializationAdmissionToken: Sendable
{
    fileprivate init()
    {
    }
}

extension NativeTextKit2Layout
{
    func materializationDiagnostics(
        indexed: LayoutIndexedProjection,
        selection: LayoutFragmentExtentSelection,
        capacity: LayoutMaterializationCapacity
    ) throws -> LayoutFragmentMaterializationDiagnostics?
    {
        let projection = indexed.projection
        let index = indexed.index
        guard projection.lineage == index.lineage.projection,
              let preflight = materializationPreflight(
                  index: index,
                  selection: selection,
                  capacity: capacity
              )
        else
        {
            return nil
        }
        let admission = LayoutMaterializationAdmissionToken()
        var accumulator = preflight.accumulator
        var materialized: [LayoutMaterializedFragment] = []
        let selected = Set(selection.extents.map(\.anchor))
        for item in preflight.ranges
        {
            let indexedExtents = index.extents[item.range]
            guard let first = indexedExtents.first,
                  let block = projectedBlock(
                      at: item.ordinal,
                      in: projection
                  ),
                  block.source == first.source,
                  let expectedFonts = indexed.resolvedFonts(
                      atBlockOrdinal: item.ordinal
                  )
            else
            {
                return nil
            }
            let laidBlock = try blockLayout(
                block,
                originY: first.frame.minY,
                parameters: index.lineage.specification.parameters
            )
            guard reconstructedBlockMatches(
                laidBlock.fragments,
                extents: indexedExtents
            ),
                  reconstructedFontsAreAdmitted(
                      laidBlock,
                      as: expectedFonts
                  ),
                  accumulator.consumeStructuralFont(of: laidBlock)
            else
            {
                return nil
            }
            for pair in zip(laidBlock.fragments, indexedExtents)
            {
                guard accumulator.consume(pair.0)
                else
                {
                    return nil
                }
                if selected.contains(pair.0.anchor)
                {
                    guard let value = LayoutMaterializedFragment(
                        admission,
                        extent: pair.1,
                        fragment: pair.0
                    )
                    else
                    {
                        return nil
                    }
                    materialized.append(value)
                }
            }
        }
        guard materialized.map(\.extent) == selection.extents,
              let usage = accumulator.usage,
              let result = LayoutFragmentMaterialization(
                  admission,
                  index: index,
                  selection: selection,
                  fragments: materialized
              )
        else
        {
            return nil
        }
        return LayoutFragmentMaterializationDiagnostics(
            admission,
            materialization: result,
            usage: usage
        )
    }

    func materialize(
        indexed: LayoutIndexedProjection,
        selection: LayoutFragmentExtentSelection,
        capacity: LayoutMaterializationCapacity
    ) throws -> LayoutFragmentMaterialization?
    {
        try materializationDiagnostics(
            indexed: indexed,
            selection: selection,
            capacity: capacity
        )?.materialization
    }
}
