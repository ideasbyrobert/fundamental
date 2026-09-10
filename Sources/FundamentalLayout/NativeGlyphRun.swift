import CoreText
import Foundation

@MainActor
struct NativeGlyphRun
{
    let range: CFRange
    let font: CTFont
    let glyphs: [CGGlyph]
    let positions: [CGPoint]
    let advances: [CGSize]
    let indices: [CFIndex]
    let matrix: CGAffineTransform

    init?(_ run: CTRun, sourceLength: Int) throws
    {
        let count = CTRunGetGlyphCount(run)
        guard count > 0
        else
        {
            return nil
        }
        let range = CTRunGetStringRange(run)
        guard range.location >= 0, range.length >= 0,
              range.location <= sourceLength,
              range.length <= sourceLength - range.location
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        var glyphs = [CGGlyph](repeating: 0, count: count)
        var positions = [CGPoint](repeating: .zero, count: count)
        var advances = [CGSize](repeating: .zero, count: count)
        var indices = [CFIndex](repeating: kCFNotFound, count: count)
        let entire = CFRange(location: 0, length: 0)
        CTRunGetGlyphs(run, entire, &glyphs)
        CTRunGetPositions(run, entire, &positions)
        CTRunGetAdvances(run, entire, &advances)
        CTRunGetStringIndices(run, entire, &indices)
        let matrix = CTRunGetTextMatrix(run)
        guard positions.allSatisfy({ $0.x.isFinite && $0.y.isFinite }),
              advances.allSatisfy({
                  $0.width.isFinite && $0.height.isFinite
              }),
              [matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty]
                .allSatisfy(\.isFinite)
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        let attributes = CTRunGetAttributes(run) as NSDictionary
        guard let font = attributes.object(forKey: kCTFontAttributeName)
            as! CTFont?
        else
        {
            throw LayoutFailure.missingResolvedFontIdentity
        }
        self.range = range
        self.font = font
        self.glyphs = glyphs
        self.positions = positions
        self.advances = advances
        self.indices = indices
        self.matrix = matrix
    }
}
