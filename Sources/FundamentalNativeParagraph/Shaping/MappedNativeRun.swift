import FundamentalParagraph
import CoreText
import Foundation

@MainActor
package struct MappedNativeRun<Source>
{
    package let range: Range<Int>
    package let font: ShapedFontIdentity
    package let matrix: CGAffineTransform
    package let status: UInt32
    package let glyphs: [MappedNativeGlyph<Source>]

    package init(
        _ native: CTRun, displayLength: Int,
        sources: (Range<Int>) throws -> [Source]
    ) throws
    {
        let raw = CTRunGetStringRange(native)
        guard raw.location >= 0, raw.length >= 0,
              raw.location <= displayLength,
              raw.length <= displayLength - raw.location
        else
        {
            throw ExplicitShapingFailure.nativeRange
        }
        range = raw.location..<(raw.location + raw.length)
        let count = CTRunGetGlyphCount(native)
        var ids = [CGGlyph](repeating: 0, count: count)
        var positions = [CGPoint](repeating: .zero, count: count)
        var advances = [CGSize](repeating: .zero, count: count)
        var indices = [CFIndex](repeating: kCFNotFound, count: count)
        let entire = CFRange(location: 0, length: 0)
        CTRunGetGlyphs(native, entire, &ids)
        CTRunGetPositions(native, entire, &positions)
        CTRunGetAdvances(native, entire, &advances)
        CTRunGetStringIndices(native, entire, &indices)
        let mapping = try NativeIndexRanges(
            range: range, indices: indices, displayLength: displayLength
        )
        matrix = CTRunGetTextMatrix(native)
        status = CTRunGetStatus(native).rawValue
        guard positions.allSatisfy({ $0.x.isFinite && $0.y.isFinite }),
              advances.allSatisfy({
                  $0.width.isFinite && $0.height.isFinite
              }),
              [matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty]
                  .allSatisfy(\.isFinite)
        else
        {
            throw ExplicitShapingFailure.nonfiniteGeometry
        }
        let attributes = CTRunGetAttributes(native) as NSDictionary
        guard let resolved = attributes[kCTFontAttributeName] as! CTFont?
        else
        {
            throw ExplicitShapingFailure.missingFontIdentity
        }
        font = try ShapedFontIdentity(resolved)
        glyphs = try indices.indices.map
        {
            index in
            MappedNativeGlyph(
                identifier: ids[index], position: positions[index],
                advance: advances[index], stringIndex: indices[index],
                displayRange: mapping.ranges[index],
                sources: try sources(mapping.ranges[index])
            )
        }
    }
}
