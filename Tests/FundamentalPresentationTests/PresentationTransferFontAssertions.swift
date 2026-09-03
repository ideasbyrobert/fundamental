import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func expectFont(
        _ source: RasterFontIdentity,
        equals result: PresentationFontIdentity
    )
    {
        #expect(source.postScriptName == result.postScriptName)
        #expect(source.uniqueName == result.uniqueName)
        #expect(source.versionName == result.versionName)
        #expect(source.pointSize == result.pointSize)
        #expect(transformSignature(source.matrix)
            == transformSignature(result.matrix))
        #expect(source.variations.map
        {
            "\($0.axis):\($0.value)"
        } == result.variations.map
        {
            "\($0.axis):\($0.value)"
        })
        #expect(source.metrics.ascent == result.metrics.ascent)
        #expect(source.metrics.descent == result.metrics.descent)
        #expect(source.metrics.leading == result.metrics.leading)
        #expect(source.metrics.capHeight == result.metrics.capHeight)
        #expect(source.metrics.xHeight == result.metrics.xHeight)
        #expect(source.metrics.underlinePosition
            == result.metrics.underlinePosition)
        #expect(source.metrics.underlineThickness
            == result.metrics.underlineThickness)
        #expect(source.metrics.unitsPerEm == result.metrics.unitsPerEm)
    }

    func transformSignature(_ value: RasterAffineTransform) -> [Double]
    {
        [value.a, value.b, value.c, value.d, value.tx, value.ty]
    }

    func transformSignature(
        _ value: PresentationAffineTransform
    ) -> [Double]
    {
        [value.a, value.b, value.c, value.d, value.tx, value.ty]
    }
}
