import FundamentalRaster

extension PresentationComposer
{
    static func font(
        _ value: RasterFontIdentity
    ) -> PresentationFontIdentity?
    {
        guard nonblank(value.postScriptName),
              nonblank(value.uniqueName),
              nonblank(value.versionName),
              value.pointSize.isFinite,
              value.pointSize > 0,
              let matrix = transform(value.matrix),
              let variations = fontVariations(
                  value.variations.map
                  {
                      ($0.axis, $0.value)
                  }
              ),
              let metrics = fontMetrics(
                  ascent: value.metrics.ascent,
                  descent: value.metrics.descent,
                  leading: value.metrics.leading,
                  capHeight: value.metrics.capHeight,
                  xHeight: value.metrics.xHeight,
                  underlinePosition: value.metrics.underlinePosition,
                  underlineThickness: value.metrics.underlineThickness,
                  unitsPerEm: value.metrics.unitsPerEm
              )
        else
        {
            return nil
        }
        return PresentationFontIdentity(
            postScriptName: value.postScriptName,
            uniqueName: value.uniqueName,
            versionName: value.versionName,
            pointSize: value.pointSize,
            matrix: matrix,
            variations: variations,
            metrics: metrics
        )
    }

    static func fontVariations(
        _ values: [(UInt32, Double)]
    ) -> [PresentationFontVariation]?
    {
        guard values.allSatisfy(
        {
            $0.1.isFinite
        })
        else
        {
            return nil
        }
        return values.map
        {
            PresentationFontVariation(axis: $0.0, value: $0.1)
        }
    }

    static func fontMetrics(
        ascent: Double,
        descent: Double,
        leading: Double,
        capHeight: Double,
        xHeight: Double,
        underlinePosition: Double,
        underlineThickness: Double,
        unitsPerEm: UInt32
    ) -> PresentationFontMetrics?
    {
        let values = [
            ascent,
            descent,
            leading,
            capHeight,
            xHeight,
            underlinePosition,
            underlineThickness
        ]
        guard values.allSatisfy(\.isFinite),
              unitsPerEm > 0
        else
        {
            return nil
        }
        return PresentationFontMetrics(
            ascent: ascent,
            descent: descent,
            leading: leading,
            capHeight: capHeight,
            xHeight: xHeight,
            underlinePosition: underlinePosition,
            underlineThickness: underlineThickness,
            unitsPerEm: unitsPerEm
        )
    }

    static func glyph(
        _ value: RasterGlyph
    ) -> PresentationGlyph?
    {
        guard let position = point(value.position),
              let advance = vector(value.advance),
              let slices = sourceSlices(value.sourceSlices)
        else
        {
            return nil
        }
        return PresentationGlyph(
            identifier: value.identifier,
            position: position,
            advance: advance,
            sourceSlices: slices
        )
    }
}
