import Testing

@testable import FundamentalLayout

extension LayoutBlockMeasurementTests
{
    func expectFormAndFontRefusal(
        _ value: LayoutBlockMeasurement
    )
    {
        #expect(readmit(
            value,
            source: value.source,
            kind: .code,
            firstExtent: value.firstExtent,
            remainingExtents: value.remainingExtents,
            contentFonts: value.contentFonts
        ) == nil)
        #expect(readmit(
            value,
            source: value.source,
            kind: value.kind,
            firstExtent: value.firstExtent,
            remainingExtents: value.remainingExtents,
            contentFonts: []
        ) == nil)
        #expect(readmit(
            value,
            source: value.source,
            kind: value.kind,
            firstExtent: value.firstExtent,
            remainingExtents: value.remainingExtents,
            contentFonts: value.contentFonts + value.contentFonts
        ) == nil)
    }
}
