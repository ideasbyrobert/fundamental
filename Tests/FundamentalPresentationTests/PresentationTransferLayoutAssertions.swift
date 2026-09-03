import Testing

@testable import FundamentalLayout
@testable import FundamentalPresentation

extension PresentationTransferTests
{
    func expectLayoutParameters(
        _ source: LayoutParameters,
        equals result: PresentationLayoutParameters
    )
    {
        #expect(source.width == result.width)
        #expect(source.blockSpacing == result.blockSpacing)
        #expect(source.rowSpacing == result.rowSpacing)
        #expect(source.columnSpacing == result.columnSpacing)
        #expect(source.cellPadding == result.cellPadding)
    }

    func expectLayoutFonts(
        _ source: [LayoutFontIdentity],
        equals result: [PresentationFontIdentity]
    )
    {
        #expect(source.count == result.count)
        for pair in zip(source, result)
        {
            #expect(pair.0.postScriptName == pair.1.postScriptName)
            #expect(pair.0.uniqueName == pair.1.uniqueName)
            #expect(pair.0.versionName == pair.1.versionName)
            #expect(pair.0.pointSize == pair.1.pointSize)
            #expect(pair.0.matrix.a == pair.1.matrix.a)
            #expect(pair.0.matrix.b == pair.1.matrix.b)
            #expect(pair.0.matrix.c == pair.1.matrix.c)
            #expect(pair.0.matrix.d == pair.1.matrix.d)
            #expect(pair.0.matrix.tx == pair.1.matrix.tx)
            #expect(pair.0.matrix.ty == pair.1.matrix.ty)
            #expect(pair.0.variations.map
            {
                "\($0.axis):\($0.value)"
            } == pair.1.variations.map
            {
                "\($0.axis):\($0.value)"
            })
            #expect(pair.0.metrics.ascent == pair.1.metrics.ascent)
            #expect(pair.0.metrics.descent == pair.1.metrics.descent)
            #expect(pair.0.metrics.leading == pair.1.metrics.leading)
            #expect(pair.0.metrics.capHeight == pair.1.metrics.capHeight)
            #expect(pair.0.metrics.xHeight == pair.1.metrics.xHeight)
            #expect(pair.0.metrics.underlinePosition
                == pair.1.metrics.underlinePosition)
            #expect(pair.0.metrics.underlineThickness
                == pair.1.metrics.underlineThickness)
            #expect(pair.0.metrics.unitsPerEm == pair.1.metrics.unitsPerEm)
        }
    }
}
