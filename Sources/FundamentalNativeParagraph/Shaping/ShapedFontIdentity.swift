import FundamentalParagraph
import CoreText
import Foundation

package struct ShapedFontIdentity: Sendable
{
    package let postScript: String
    package let unique: String
    package let version: String
    package let pointSize: Double
    package let symbolicTraits: UInt32
    package let matrix: CGAffineTransform
    package let variations: [[Double]]

    package init(_ font: CTFont) throws
    {
        guard let unique = CTFontCopyName(font, kCTFontUniqueNameKey)
                  as String?,
              let version = CTFontCopyName(font, kCTFontVersionNameKey)
                  as String?
        else
        {
            throw ExplicitShapingFailure.missingFontIdentity
        }
        postScript = CTFontCopyPostScriptName(font) as String
        self.unique = unique
        self.version = version
        pointSize = CTFontGetSize(font)
        symbolicTraits = CTFontGetSymbolicTraits(font).rawValue
        matrix = CTFontGetMatrix(font)
        let axes = CTFontCopyVariation(font) as? [NSNumber: NSNumber] ?? [:]
        variations = axes.map
        {
            [$0.key.doubleValue, $0.value.doubleValue]
        }.sorted { $0[0] < $1[0] }
        guard [pointSize, matrix.a, matrix.b, matrix.c, matrix.d,
               matrix.tx, matrix.ty].allSatisfy(\.isFinite),
              variations.joined().allSatisfy(\.isFinite)
        else
        {
            throw ExplicitShapingFailure.nonfiniteGeometry
        }
    }
}
