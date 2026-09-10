import FundamentalRaster

extension PresentationComposer
{
    static func fill(
        _ value: RasterFill,
        specification: PresentationRasterSpecificationIdentity
    ) -> PresentationFill?
    {
        guard let identifier = residentID(value.residentID),
              let bounds = rectangle(value.logicalBounds),
              contains(specification.logicalBounds, bounds),
              let pixels = pixelBounds(
                  value.pixelBounds,
                  logicalBounds: bounds,
                  backingScale: specification.backingScale
              ),
              let color = color(value.color),
              color.colorSpace == specification.colorSpace,
              let slices = sourceSlices(value.sourceSlices)
        else
        {
            return nil
        }
        let role: PresentationFillRole
        switch value.role
        {
        case .tableBackground:
            role = .tableBackground
        case .headerBackground:
            role = .headerBackground
        case .tableRule:
            role = .tableRule
        case .underline:
            role = .underline
        case .strikethrough:
            role = .strikethrough
        }
        return PresentationFill(
            residentID: identifier,
            role: role,
            logicalBounds: bounds,
            pixelBounds: pixels,
            color: color,
            sourceSlices: slices
        )
    }
}
