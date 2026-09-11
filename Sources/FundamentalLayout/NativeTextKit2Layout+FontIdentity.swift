import AppKit
import CoreText

extension NativeTextKit2Layout
{
    func fontIdentity(_ font: CTFont) throws -> LayoutFontIdentity
    {
        let postScriptName = CTFontCopyPostScriptName(font) as String
        guard let uniqueName = CTFontCopyName(
            font,
            kCTFontUniqueNameKey
        ) as String?,
              let versionName = CTFontCopyName(
                  font,
                  kCTFontVersionNameKey
              ) as String?
        else
        {
            throw LayoutFailure.missingResolvedFontIdentity
        }
        let matrix = CTFontGetMatrix(font)
        let metrics = [
            matrix.a,
            matrix.b,
            matrix.c,
            matrix.d,
            matrix.tx,
            matrix.ty,
            CTFontGetSize(font),
            CTFontGetAscent(font),
            CTFontGetDescent(font),
            CTFontGetLeading(font),
            CTFontGetCapHeight(font),
            CTFontGetXHeight(font),
            CTFontGetUnderlinePosition(font),
            CTFontGetUnderlineThickness(font)
        ]
        guard metrics.allSatisfy(\.isFinite)
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        let variationDictionary = CTFontCopyVariation(font)
            as? [NSNumber: NSNumber] ?? [:]
        let variations = variationDictionary.map
        {
            LayoutFontVariation(
                axis: $0.key.uint32Value,
                value: $0.value.doubleValue
            )
        }.sorted
        {
            $0.axis < $1.axis
        }
        guard variations.allSatisfy({ $0.value.isFinite })
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        return LayoutFontIdentity(
            postScriptName: postScriptName,
            uniqueName: uniqueName,
            versionName: versionName,
            pointSize: CTFontGetSize(font),
            matrix: LayoutAffineTransform(
                a: matrix.a,
                b: matrix.b,
                c: matrix.c,
                d: matrix.d,
                tx: matrix.tx,
                ty: matrix.ty
            ),
            variations: variations,
            metrics: LayoutFontMetrics(
                ascent: CTFontGetAscent(font),
                descent: CTFontGetDescent(font),
                leading: CTFontGetLeading(font),
                capHeight: CTFontGetCapHeight(font),
                xHeight: CTFontGetXHeight(font),
                underlinePosition: CTFontGetUnderlinePosition(font),
                underlineThickness: CTFontGetUnderlineThickness(font),
                unitsPerEm: CTFontGetUnitsPerEm(font)
            )
        )
    }
}
