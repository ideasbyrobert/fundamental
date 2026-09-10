import CoreText

@testable import FundamentalPresentation

extension MacBitmapSurface
{
    func drawNativeLine(
        _ line: CTLine, batch: PresentationGlyphBatch,
        origin: PresentationPoint
    )
    {
        let clip = batch.clipBounds
        context.saveGState()
        context.scaleBy(x: backingScale, y: backingScale)
        context.translateBy(
            x: -logicalMinimumX,
            y: logicalMinimumY + Double(height) / backingScale
        )
        context.scaleBy(x: 1, y: -1)
        context.clip(to: CGRect(
            x: clip.minX, y: clip.minY,
            width: clip.size.width, height: clip.size.height
        ))
        context.translateBy(x: origin.x, y: origin.y)
        context.scaleBy(x: 1, y: -1)
        context.textMatrix = .identity
        context.textPosition = CGPoint(
            x: batch.firstGlyph.position.x - origin.x,
            y: origin.y - batch.firstGlyph.position.y
        )
        CTLineDraw(line, context)
        context.restoreGState()
        context.flush()
    }
}
