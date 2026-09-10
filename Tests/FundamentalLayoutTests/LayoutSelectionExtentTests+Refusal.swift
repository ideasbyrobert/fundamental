import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutSelectionExtentTests
{
    @Test("the unsupported mixed-LTR shaping check remains intact",
          arguments: [240.0, 480.0])
    func mixedLTRRefusal(width: Double) throws
    {
        let projection = try LayoutFixture.projection([
            .paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct("AB אב\n")
            ]))
        ])
        do
        {
            _ = try NativeTextKit2Layout().layout(
                projection, request: LayoutFixture.request(width: width)
            )
            Issue.record("The unsupported shaping discrepancy was admitted")
        }
        catch LayoutFailure.inconsistentNativeShaping(_, _)
        {
        }
    }
}
