@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import AppKit
import Testing

@MainActor
@Suite
struct ShapedRefusalTests
{
    @Test
    func invalidOffsetsAndMutableParagraphStylesFailAdmission() throws
    {
        let value = try ShapingFixture.collection("a")
        for offset in [-1.0, .nan, .infinity]
        {
            #expect(throws: ExplicitShapingFailure.nativeMeasurement)
            {
                try ShapingFixture.line(value, range: 0..<1, offset: offset)
            }
        }
        #expect(throws: ExplicitShapingFailure.nativeMeasurement)
        {
            try ExplicitShapedLine(value, range: 0..<1)
            {
                var attributes = try ShapingFixture.attributes($0, size: 18)
                attributes[.paragraphStyle] = NSMutableParagraphStyle()
                return attributes
            }
        }
        try PatternEvidence.write("native-admission", group: "shaping-controls",
                                  record: ["offsetRefusals": 3,
                                           "mutableStyleRefusals": 1])
    }

    @Test
    func foreignSelectionCannotAuthorizeShaping() throws
    {
        let first = try ShapingFixture.collection("extra\u{AD}ordinary")
        let second = try ShapingFixture.collection("extra\u{AD}ordinary")
        let selection = try first.select(0)
        #expect(throws: ExplicitProjectionFailure.foreignSelection)
        {
            try ShapingFixture.line(
                second, range: 0..<6, end: .opportunity(selection)
            )
        }
        #expect(throws: ExplicitProjectionFailure.hardEnding)
        {
            try ShapingFixture.line(
                ShapingFixture.collection("a\nb"), range: 0..<3
            )
        }
        try PatternEvidence.write("source-admission", group: "shaping-controls",
                                  record: ["foreignParent": 1, "hardEnding": 1])
    }
}
