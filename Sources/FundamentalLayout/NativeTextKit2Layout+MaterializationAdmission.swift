import FundamentalProjection

extension NativeTextKit2Layout
{
    func materializationPreflight(
        index: LayoutDocumentExtentIndex,
        selection: LayoutFragmentExtentSelection,
        capacity: LayoutMaterializationCapacity
    ) -> (
        ranges: [(ordinal: Int, range: Range<Int>)],
        accumulator: LayoutMaterializationAccumulator
    )?
    {
        guard selection.lineage == index.lineage
        else
        {
            return nil
        }
        var ranges: [(ordinal: Int, range: Range<Int>)] = []
        var seen = Set<Int>()
        var fragmentCount = 0
        for extent in selection.extents
        where seen.insert(extent.anchor.blockOrdinal).inserted
        {
            guard let range = index.completeExtentRange(
                containing: extent
            )
            else
            {
                return nil
            }
            let next = fragmentCount.addingReportingOverflow(range.count)
            guard !next.overflow
            else
            {
                return nil
            }
            fragmentCount = next.partialValue
            ranges.append((extent.anchor.blockOrdinal, range))
        }
        guard let accumulator = LayoutMaterializationAccumulator(
            capacity: capacity,
            reconstructedBlocks: ranges.count,
            reconstructedFragments: fragmentCount,
            materializedFragments: selection.extents.count
        )
        else
        {
            return nil
        }
        return (ranges, accumulator)
    }

    func projectedBlock(
        at ordinal: Int,
        in projection: ProjectionSnapshot
    ) -> ProjectedBlock?
    {
        guard ordinal >= 0
        else
        {
            return nil
        }
        let block: ProjectedBlock
        if ordinal == 0
        {
            block = projection.firstBlock
        }
        else
        {
            let index = ordinal - 1
            guard projection.remainingBlocks.indices.contains(index)
            else
            {
                return nil
            }
            block = projection.remainingBlocks[index]
        }
        guard block.source.ordinal == ordinal
        else
        {
            return nil
        }
        return block
    }

    func reconstructedBlockMatches(
        _ fragments: [LayoutFragment],
        extents: ArraySlice<LayoutPlacedFragmentExtent>
    ) -> Bool
    {
        guard fragments.count == extents.count
        else
        {
            return false
        }
        return zip(fragments, extents).allSatisfy
        {
            LayoutMaterializedFragment.matches($0.0, extent: $0.1)
        }
    }

    func reconstructedFontsAreAdmitted(
        _ block: NativeBlockLayout,
        as expected: [LayoutFontIdentity]
    ) -> Bool
    {
        let reconstructed = resolvedFonts(
            in: block.fragments,
            grids: block.grids
        )
        return reconstructed == expected
    }
}
