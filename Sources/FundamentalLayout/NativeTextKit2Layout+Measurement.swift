import FundamentalProjection

extension NativeTextKit2Layout
{
    func measure(
        _ block: ProjectedBlock,
        parameters: LayoutParameters
    ) throws -> LayoutBlockMeasurement
    {
        let layout = try blockLayout(
            block,
            originY: 0,
            parameters: parameters
        )
        let extents = layout.fragments.map(LayoutFragmentExtent.init)
        let contentFonts = resolvedContentFonts(in: layout.fragments)
        guard let firstExtent = extents.first,
              let measurement = LayoutBlockMeasurement(
                  source: block.source,
                  parameters: parameters,
                  kind: layout.kind,
                  firstExtent: firstExtent,
                  remainingExtents: Array(extents.dropFirst()),
                  contentFonts: contentFonts
              )
        else
        {
            throw LayoutFailure.unrepresentableBlockMeasurement
        }
        return measurement
    }
}
