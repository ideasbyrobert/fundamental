import FundamentalViewport

extension ViewportRasterizer
{
    static func append(
        _ line: ResidentLayoutLine,
        residentID: RasterResidentID,
        residence: RasterResidence,
        role: RasterInteractionRole,
        frame: RasterRectangle,
        targetBounds: RasterRectangle,
        specification: RasterSpecificationIdentity,
        accumulator: inout RasterAccumulator
    ) -> Bool
    {
        guard let lineBounds = rectangle(
            x: line.frame.minX,
            y: line.frame.minY,
            width: line.frame.size.width,
            height: line.frame.size.height
        ),
              let baseline = RasterPoint(
                  x: line.baseline.x,
                  y: line.baseline.y
              ),
              let clipBounds = frame.intersection(targetBounds),
              let pixelBounds = RasterPixelBounds(
                  logicalBounds: clipBounds,
                  backingScale: specification.backingScale
              ),
              let carets = caretSites(line)
        else
        {
            return false
        }
        let lineSlices = sourceSlices(line.sourceSlices)
        for run in line.glyphRuns
        {
            let count = 1 + run.remainingGlyphs.count
            var glyphs: [RasterGlyph] = []
            glyphs.reserveCapacity(count)
            for index in 0 ..< count
            {
                let glyph = index == 0
                    ? run.firstGlyph
                    : run.remainingGlyphs[index - 1]
                guard let position = RasterPoint(
                    x: glyph.position.x,
                    y: glyph.position.y
                )
                else
                {
                    return false
                }
                glyphs.append(RasterGlyph(
                    identifier: glyph.identifier,
                    position: position,
                    advance: RasterVector(
                        dx: glyph.advance.dx,
                        dy: glyph.advance.dy
                    ),
                    sourceSlices: sourceSlices(glyph.sourceSlices)
                ))
            }
            guard let firstGlyph = glyphs.first,
                  accumulator.append(RasterGlyphBatch(
                      residentID: residentID,
                      paintOrder: run.paintOrder,
                      logicalBounds: lineBounds,
                      clipBounds: clipBounds,
                      pixelBounds: pixelBounds,
                      font: font(run.font),
                      textMatrix: transform(
                          a: run.textMatrix.a,
                          b: run.textMatrix.b,
                          c: run.textMatrix.c,
                          d: run.textMatrix.d,
                          tx: run.textMatrix.tx,
                          ty: run.textMatrix.ty
                      ),
                      baselineOffset: run.style.baselineOffset,
                      color: specification.palette.text,
                      sourceSlices: sourceSlices(run.sourceSlices),
                      firstGlyph: firstGlyph,
                      remainingGlyphs: Array(glyphs.dropFirst())
                  )),
                  appendDecorations(
                      run,
                      residentID: residentID,
                      targetBounds: targetBounds,
                      specification: specification,
                      accumulator: &accumulator
                  )
            else
            {
                return false
            }
        }
        guard let firstCaret = carets.first
        else
        {
            return false
        }
        let text = RasterInteractionText(
            text: line.text,
            defaultFont: font(line.defaultFont),
            lineBounds: lineBounds,
            baseline: baseline,
            sourceSlices: lineSlices,
            firstCaretSite: firstCaret,
            remainingCaretSites: Array(carets.dropFirst())
        )
        return accumulator.append(RasterInteractionRegion(
            residentID: residentID,
            residence: residence,
            role: role,
            frame: frame,
            content: .text(text)
        ))
    }

    private static func caretSites(
        _ line: ResidentLayoutLine
    ) -> [RasterCaretSite]?
    {
        let count = 1 + line.remainingCaretStops.count
        var sites: [RasterCaretSite] = []
        sites.reserveCapacity(count)
        for index in 0 ..< count
        {
            let stop = index == 0
                ? line.firstCaretStop
                : line.remainingCaretStops[index - 1]
            guard let position = RasterPoint(
                x: stop.position.x,
                y: stop.position.y
            )
            else
            {
                return nil
            }
            let point: RasterTextPoint
            switch stop.sourcePoint
            {
            case let .block(blockID, offset):
                point = .block(
                    blockID: blockID,
                    utf16Offset: offset
                )
            case let .caption(blockID, offset):
                point = .caption(
                    blockID: blockID,
                    utf16Offset: offset
                )
            case let .cell(blockID, row, cell, offset):
                point = .cell(
                    blockID: blockID,
                    row: row,
                    cell: cell,
                    utf16Offset: offset
                )
            }
            sites.append(RasterCaretSite(
                utf16Offset: stop.utf16Offset,
                position: position,
                sourcePoint: point
            ))
        }
        return sites
    }

    private static func appendDecorations(
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
