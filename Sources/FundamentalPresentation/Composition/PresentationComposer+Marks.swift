import FundamentalRaster

extension PresentationComposer
{
    static func marks(
        _ values: [RasterMark],
        specification: PresentationRasterSpecificationIdentity
    ) -> [PresentationMark]?
    {
        var result: [PresentationMark] = []
        result.reserveCapacity(values.count)
        for value in values
        {
            guard let mark = mark(value, specification: specification)
            else
            {
                return nil
            }
            result.append(mark)
        }
        return result
    }

    static func mark(
        _ value: RasterMark,
        specification: PresentationRasterSpecificationIdentity
    ) -> PresentationMark?
    {
        switch value
        {
        case let .glyphs(batch):
            guard let batch = glyphBatch(
                batch,
                specification: specification
            )
            else
            {
                return nil
            }
            return .glyphs(batch)
        case let .fill(value):
            guard let converted = fill(
                value,
                specification: specification
            )
            else
            {
                return nil
            }
            return .fill(converted)
        }
    }

    static func glyphBatch(
        _ value: RasterGlyphBatch,
        specification: PresentationRasterSpecificationIdentity
    ) -> PresentationGlyphBatch?
    {
        guard value.paintOrder >= 0,
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

    static func contains(
        _ outer: PresentationRectangle,
        _ inner: PresentationRectangle
    ) -> Bool
    {
        inner.minX >= outer.minX
            && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX
            && inner.maxY <= outer.maxY
    }
}
