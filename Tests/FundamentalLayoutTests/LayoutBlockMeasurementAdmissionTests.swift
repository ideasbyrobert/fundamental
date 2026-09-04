import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutBlockMeasurementTests
{
    @MainActor
    @Test("counterfeit source form fonts and table counts are refused")
    func admissionRefusal() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct(String(
                repeating: "Measured local content ",
                count: 20
            ))
        ]))
        let value = try product(block, width: 120).measurement
        try expectAddressRefusal(value, block: block)
        try expectGeometryRefusal(value)
        expectFormAndFontRefusal(value)
        try expectTableRefusal()
    }
}
