import FundamentalViewport

extension ViewportRasterizer
{
    static func append(
        _ run: ResidentLayoutGlyphRun,
        source: RasterGlyphSource, residentID: RasterResidentID,
        geometry: RasterLineGeometry, targetBounds: RasterRectangle,
        specification: RasterSpecificationIdentity,
        accumulator: inout RasterAccumulator
    ) -> Bool
    {
        guard let glyphs = glyphs(run), let first = glyphs.first,
              accumulator.append(RasterGlyphBatch(
                  residentID: residentID,
                  paintOrder: run.paintOrder,
                  logicalBounds: geometry.bounds,
                  clipBounds: geometry.clip,
                  pixelBounds: geometry.pixels,
                  font: font(run.font),
                  textMatrix: transform(
                      a: run.textMatrix.a, b: run.textMatrix.b,
                      c: run.textMatrix.c, d: run.textMatrix.d,
                      tx: run.textMatrix.tx, ty: run.textMatrix.ty
                  ),
                  baselineOffset: run.style.baselineOffset,
                  color: specification.palette.text,
                  source: source,
                  firstGlyph: first,
                  remainingGlyphs: Array(glyphs.dropFirst())
              ))
        else
        {
            return false
        }
        return appendDecorations(
            run, residentID: residentID, targetBounds: targetBounds,
            specification: specification, accumulator: &accumulator
        )
    }
}
