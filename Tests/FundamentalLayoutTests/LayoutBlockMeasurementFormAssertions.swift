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
            block: value.block,
            kind: .code,
            firstExtent: value.firstExtent,
            remainingExtents: value.remainingExtents,
            contentFonts: value.contentFonts
        ) == nil)
        #expect(readmit(
            value,
            block: value.block,
            kind: value.kind,
            firstExtent: value.firstExtent,
            remainingExtents: value.remainingExtents,
            contentFonts: []
        ) == nil)
        #expect(readmit(
            value,
            block: value.block,
            kind: value.kind,
            firstExtent: value.firstExtent,
            remainingExtents: value.remainingExtents,
            contentFonts: value.contentFonts + value.contentFonts
        ) == nil)
    }
}
