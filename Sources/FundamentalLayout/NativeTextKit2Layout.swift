import FundamentalProjection

@MainActor
struct NativeTextKit2Layout
{
    init()
    {
    }

    func layout(
        _ projection: ProjectionSnapshot,
        request: LayoutRequest
    ) throws -> LayoutSnapshot
    {
        let parameters = request.parameters
        var fragments: [LayoutFragment] = []
        var grids: [LayoutGrid] = []
        var nextY = 0.0
        for (blockIndex, block) in projection.blocks.enumerated()
        {
            if blockIndex > 0
            {
                nextY += parameters.blockSpacing
            }
            let laidBlock = try blockLayout(
                block,
                originY: nextY,
                parameters: parameters
            )
            fragments += laidBlock.fragments
            grids += laidBlock.grids
            nextY = laidBlock.maximumY
        }
        let maximumX = fragments.map(\.frame.maxX).max()
            ?? parameters.width
        guard let size = LayoutSize(
            width: max(parameters.width, maximumX),
            height: nextY
        )
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        let fonts = resolvedFonts(
            in: fragments,
            grids: grids
        )
        let specification = LayoutSpecificationIdentity(
            parameters: parameters,
            resolvedFonts: fonts
        )
        return LayoutSnapshot(
            lineage: LayoutLineage(
                projection: projection.lineage,
                generation: request.generation,
                specification: specification
            ),
            size: size,
            firstFragment: fragments[0],
            remainingFragments: Array(fragments.dropFirst()),
            grids: grids
        )
    }
}
