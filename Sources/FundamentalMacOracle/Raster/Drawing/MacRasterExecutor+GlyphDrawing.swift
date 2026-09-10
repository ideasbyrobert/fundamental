import CoreGraphics
import CoreText

extension MacRasterExecutor
{
    func draw(
        _ mark: MacAdmittedRasterMark,
        in context: CGContext
    )
    {
        switch mark
        {
        case let .fill(fill):
            context.setFillColor(fill.color.graphics)
            context.fill(fill.logicalBounds)
        case let .glyphs(batch):
            context.saveGState()
            context.clip(to: batch.clipBounds)
            context.translateBy(x: batch.origin.x, y: batch.origin.y)
            context.setFillColor(batch.color.graphics)
            context.setTextDrawingMode(.fill)
            context.textMatrix = Self.nativeTextMatrix
            CTFontDrawGlyphs(
                batch.font.native,
                batch.glyphs,
                batch.positions,
                batch.glyphs.count,
                context
            )
            context.restoreGState()
        }
    }

    private static let nativeTextMatrix = CGAffineTransform(
        a: 1,
        b: 0,
        c: 0,
        d: -1,
        tx: 0,
        ty: 0
    )
}
