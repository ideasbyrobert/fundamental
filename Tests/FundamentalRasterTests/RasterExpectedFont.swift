@testable import FundamentalLayout
@testable import FundamentalRaster

extension RasterFixture
{
    static func expectedFont(
        _ font: LayoutFontIdentity
    ) -> RasterFontIdentity
    {
        RasterFontIdentity(
            postScriptName: font.postScriptName,
            uniqueName: font.uniqueName,
            versionName: font.versionName,
            pointSize: font.pointSize,
            matrix: expectedTransform(font.matrix),
            variations: font.variations.map
            {
                RasterFontVariation(axis: $0.axis, value: $0.value)
            },
            metrics: RasterFontMetrics(
                ascent: font.metrics.ascent,
                descent: font.metrics.descent,
                leading: font.metrics.leading,
                capHeight: font.metrics.capHeight,
                xHeight: font.metrics.xHeight,
                underlinePosition: font.metrics.underlinePosition,
                underlineThickness: font.metrics.underlineThickness,
                unitsPerEm: font.metrics.unitsPerEm
            )
        )
    }

    static func expectedTransform(
        _ value: LayoutAffineTransform
    ) -> RasterAffineTransform
    {
        RasterAffineTransform(
            a: value.a,
            b: value.b,
            c: value.c,
            d: value.d,
            tx: value.tx,
            ty: value.ty
        )
    }
}
