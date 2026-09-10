import FundamentalRaster

extension PresentationComposer
{
    static func glyphBatch(
        _ value: RasterGlyphBatch,
        specification: PresentationRasterSpecificationIdentity
    ) -> PresentationGlyphBatch?
    {
        guard case .text = value.source,
              value.paintOrder >= 0,
              value.baselineOffset.isFinite,
              let identifier = residentID(value.residentID),
              let logicalBounds = rectangle(value.logicalBounds),
              let clipBounds = rectangle(value.clipBounds),
              contains(specification.logicalBounds, clipBounds),
              let pixels = pixelBounds(
                  value.pixelBounds,
                  logicalBounds: clipBounds,
                  backingScale: specification.backingScale
              ),
              let font = font(value.font),
              let matrix = transform(value.textMatrix),
              let color = color(value.color),
              color.colorSpace == specification.colorSpace,
              let slices = sourceSlices(value.sourceSlices),
              let firstGlyph = glyph(value.firstGlyph)
        else
        {
            return nil
        }
        var remaining: [PresentationGlyph] = []
        remaining.reserveCapacity(value.remainingGlyphs.count)
        for value in value.remainingGlyphs
        {
            guard let value = glyph(value)
            else
            {
                return nil
            }
            remaining.append(value)
        }
        return PresentationGlyphBatch(
            residentID: identifier,
            paintOrder: value.paintOrder,
            logicalBounds: logicalBounds,
            clipBounds: clipBounds,
            pixelBounds: pixels,
            font: font,
            textMatrix: matrix,
            baselineOffset: value.baselineOffset,
            color: color,
            sourceSlices: slices,
            firstGlyph: firstGlyph,
            remainingGlyphs: remaining
        )
    }
}
