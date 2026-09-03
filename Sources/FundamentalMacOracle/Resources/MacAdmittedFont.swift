import AppKit
import CoreGraphics
import CoreText
import Foundation
import FundamentalPresentation

@MainActor
package struct MacAdmittedFont
{
    package let native: CTFont

    package init?(
        _ identity: PresentationFontIdentity,
        sourceText: String
    )
    {
        var matrix = CGAffineTransform(
            a: identity.matrix.a,
            b: identity.matrix.b,
            c: identity.matrix.c,
            d: identity.matrix.d,
            tx: identity.matrix.tx,
            ty: identity.matrix.ty
        )
        let native: CTFont
        if identity.uniqueName.contains(";")
        {
            guard let recovered = Self.recover(
                identity,
                sourceText: sourceText
            )
            else
            {
                return nil
            }
            native = recovered
        }
        else
        {
            let named = CTFontCreateWithName(
                identity.uniqueName as CFString,
                identity.pointSize,
                &matrix
            )
            if Self.matches(named, identity: identity)
            {
                native = named
            }
            else
            {
                let postScriptNamed = CTFontCreateWithName(
                    identity.postScriptName as CFString,
                    identity.pointSize,
                    &matrix
                )
                if Self.matches(postScriptNamed, identity: identity)
                {
                    native = postScriptNamed
                }
                else if let recovered = Self.recover(
                    identity,
                    sourceText: sourceText
                )
                {
                    native = recovered
                }
                else
                {
                    return nil
                }
            }
        }
        guard Self.matches(native, identity: identity)
        else
        {
            return nil
        }
        self.native = native
    }

    private static func recover(
        _ identity: PresentationFontIdentity,
        sourceText: String
    ) -> CTFont?
    {
        guard !sourceText.isEmpty
        else
        {
            return nil
        }
        let fonts = [
            NSFont.systemFont(
                ofSize: identity.pointSize,
                weight: .regular
            ),
            NSFont.systemFont(
                ofSize: identity.pointSize,
                weight: .semibold
            ),
            NSFont.systemFont(
                ofSize: identity.pointSize,
                weight: .bold
            ),
            NSFont.monospacedSystemFont(
                ofSize: identity.pointSize,
                weight: .regular
            )
        ]
        let string = sourceText as CFString
        let range = CFRange(
            location: 0,
            length: CFStringGetLength(string)
        )
        for font in fonts
        {
            let candidate = CTFontCreateForString(
                font as CTFont,
                string,
                range
            )
            if matches(candidate, identity: identity)
            {
                return candidate
            }
        }
        return nil
    }

    private static func matches(
        _ font: CTFont,
        identity: PresentationFontIdentity
    ) -> Bool
    {
        let unique = CTFontCopyName(font, kCTFontUniqueNameKey) as String?
        let version = CTFontCopyName(font, kCTFontVersionNameKey) as String?
        let matrix = CTFontGetMatrix(font)
        let metricsMatch = CTFontGetAscent(font) == identity.metrics.ascent
            && CTFontGetDescent(font) == identity.metrics.descent
            && CTFontGetLeading(font) == identity.metrics.leading
            && CTFontGetCapHeight(font) == identity.metrics.capHeight
            && CTFontGetXHeight(font) == identity.metrics.xHeight
            && CTFontGetUnderlinePosition(font)
                == identity.metrics.underlinePosition
            && CTFontGetUnderlineThickness(font)
                == identity.metrics.underlineThickness
            && CTFontGetUnitsPerEm(font) == identity.metrics.unitsPerEm
        return CTFontCopyPostScriptName(font) as String
                == identity.postScriptName
            && unique == identity.uniqueName
            && version == identity.versionName
            && CTFontGetSize(font) == identity.pointSize
            && matrix.a == identity.matrix.a
            && matrix.b == identity.matrix.b
            && matrix.c == identity.matrix.c
            && matrix.d == identity.matrix.d
            && matrix.tx == identity.matrix.tx
            && matrix.ty == identity.matrix.ty
            && metricsMatch
            && variationsMatch(font, identity: identity)
    }

    private static func variationsMatch(
        _ font: CTFont,
        identity: PresentationFontIdentity
    ) -> Bool
    {
        let values = CTFontCopyVariation(font)
            as? [NSNumber: NSNumber] ?? [:]
        let sorted = values.map
        {
            ($0.key.uint32Value, $0.value.doubleValue)
        }.sorted
        {
            $0.0 < $1.0
        }
        guard sorted.count == identity.variations.count
        else
        {
            return false
        }
        return zip(sorted, identity.variations).allSatisfy
        {
            native, admitted in
            native.0 == admitted.axis && native.1 == admitted.value
        }
    }
}
