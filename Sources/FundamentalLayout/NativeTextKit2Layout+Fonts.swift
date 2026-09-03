import AppKit
import CoreText
import FundamentalProjection

extension NativeTextKit2Layout
{
    func proseFont(_ role: ProjectedProseRole) throws -> NSFont
    {
        switch role
        {
        case .body:
            try serifFont(ofSize: 17, weight: .regular)
        case .title:
            try serifFont(ofSize: 28, weight: .semibold)
        case let .section(level):
            try serifFont(
                ofSize: sectionFontSize(level),
                weight: .semibold
            )
        }
    }

    func serifFont(
        ofSize size: Double,
        weight: NSFont.Weight
    ) throws -> NSFont
    {
        let base = NSFont.systemFont(
            ofSize: size,
            weight: weight
        )
        guard let descriptor = base.fontDescriptor.withDesign(.serif),
              let resolved = NSFont(
                  descriptor: descriptor,
                  size: size
              )
        else
        {
            throw LayoutFailure.missingResolvedFontIdentity
        }
        return resolved
    }

    func sectionFontSize(_ level: ProjectedHeadingLevel) -> Double
    {
        switch level
        {
        case .one:
            24
        case .two:
            22
        case .three:
            20
        case .four:
            19
        case .five:
            18
        case .six:
            17
        }
    }

    func tableFont(_ scope: LayoutTableRowScope) throws -> NSFont
    {
        switch scope
        {
        case .header:
            try serifFont(ofSize: 15, weight: .semibold)
        case .body:
            try serifFont(ofSize: 15, weight: .regular)
        }
    }

    func captionFont() throws -> NSFont
    {
        try serifFont(ofSize: 14, weight: .regular)
    }

    func attributes(
        font: NSFont,
        traits: Set<ProjectedInlineTrait>
    ) throws -> [NSAttributedString.Key: Any]
    {
        var selectedFont = font
        var symbolic: NSFontDescriptor.SymbolicTraits = []
        if traits.contains(.strong)
        {
            symbolic.insert(.bold)
        }
        if traits.contains(.emphasis)
        {
            symbolic.insert(.italic)
        }
        if traits.contains(.inlineCode)
        {
            selectedFont = .monospacedSystemFont(
                ofSize: font.pointSize,
                weight: .regular
            )
        }
        if !symbolic.isEmpty
        {
            guard let converted = NSFont(
                descriptor: selectedFont.fontDescriptor
                    .withSymbolicTraits(symbolic),
                size: selectedFont.pointSize
            )
            else
            {
                throw LayoutFailure.missingResolvedFontIdentity
            }
            selectedFont = converted
        }
        var attributes: [NSAttributedString.Key: Any] = [
            .font: selectedFont
        ]
        if traits.contains(.underline)
        {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        if traits.contains(.strikethrough)
        {
            attributes[.strikethroughStyle] =
                NSUnderlineStyle.single.rawValue
        }
        if traits.contains(.superscript)
        {
            attributes[.baselineOffset] = font.pointSize * 0.3
        }
        if traits.contains(.subscriptText)
        {
            attributes[.baselineOffset] = -font.pointSize * 0.2
        }
        return attributes
    }

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
