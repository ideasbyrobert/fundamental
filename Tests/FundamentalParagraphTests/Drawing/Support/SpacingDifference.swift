@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Foundation

@MainActor
enum SpacingDifference
{
    static func record(
        _ name: String, _ actual: SpacingRaster, _ expected: SpacingRaster
    ) throws
    {
        guard actual.bytes != expected.bytes
        else
        {
            return
        }
        try SpacingCapture.write(
            expected, name: name, group: "spacing-differences"
        )
        let indices = stride(from: 0, to: actual.bytes.count, by: 4).filter
        {
            actual.bytes[$0..<($0 + 4)] != expected.bytes[$0..<($0 + 4)]
        }
        let pixels = indices.prefix(80).map
        {
            [
                "x": $0 / 4 % actual.width, "y": $0 / 4 / actual.width,
                "actual": Array(actual.bytes[$0..<($0 + 4)]),
                "expected": Array(expected.bytes[$0..<($0 + 4)])
            ] as [String: Any]
        }
        try PatternEvidence.write(name, group: "spacing-differences", record: [
            "changedPixels": indices.count, "pixels": pixels,
            "actualBounds": SpacingEvidence.rectangle(actual.pixelBounds),
            "expectedBounds": SpacingEvidence.rectangle(expected.pixelBounds)
        ])
    }
}
