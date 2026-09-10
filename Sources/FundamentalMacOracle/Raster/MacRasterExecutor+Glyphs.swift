import CoreGraphics
import FundamentalPresentation

extension MacRasterExecutor
{
    func admit(
        _ batch: PresentationGlyphBatch,
        origin: PresentationPoint,
        colorSpace: MacAdmittedColorSpace
    ) -> MacAdmittedRasterMark?
    {
        guard Self.admitsTextMatrix(batch.textMatrix),
              batch.glyphs.allSatisfy(
                  { $0.identifier <= UInt16.max }
              ),
              let font = MacAdmittedFont(
                  batch.font,
                  sourceText: batch.sourceSlices.map(\.text).joined()
              ),
              let color = MacAdmittedColor(
                  batch.color,
                  colorSpace: colorSpace
              )
        else
        {
            return nil
        }
        var positions: [CGPoint] = []
        positions.reserveCapacity(batch.glyphs.count)
        for glyph in batch.glyphs
        {
            let x = glyph.position.x - origin.x
            let y = origin.y - glyph.position.y
            guard x.isFinite, y.isFinite
            else
            {
                return nil
            }
            positions.append(CGPoint(x: x, y: y))
        }
        return .glyphs(MacAdmittedGlyphExecution(
            residentID: batch.residentID,
            font: font,
            color: color,
            origin: CGPoint(x: origin.x, y: origin.y),
            glyphs: batch.glyphs.map
            {
                CGGlyph($0.identifier)
            },
            positions: positions,
            clipBounds: Self.rectangle(batch.clipBounds)
        ))
    }
}
