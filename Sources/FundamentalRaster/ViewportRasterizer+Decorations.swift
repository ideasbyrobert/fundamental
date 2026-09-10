import FundamentalViewport

extension ViewportRasterizer
{
    static func appendDecorations(
        _ run: ResidentLayoutGlyphRun,
        residentID: RasterResidentID,
        targetBounds: RasterRectangle,
        specification: RasterSpecificationIdentity,
        accumulator: inout RasterAccumulator
    ) -> Bool
    {
        for decoration in run.decorations
        {
            let role: RasterFillRole
            switch decoration.kind
            {
            case .underline:
                role = .underline
            case .strikethrough:
                role = .strikethrough
            }
            guard let bounds = rectangle(
                x: decoration.frame.minX,
                y: decoration.frame.minY,
                width: decoration.frame.size.width,
                height: decoration.frame.size.height
            ),
                  appendFill(
                      residentID: residentID,
                      role: role,
                      bounds: bounds,
                      targetBounds: targetBounds,
                      color: specification.palette.decoration,
                      sourceSlices: sourceSlices(
                          decoration.sourceSlices
                      ),
                      specification: specification,
                      accumulator: &accumulator
                  )
            else
            {
                return false
            }
        }
        return true
    }
}
