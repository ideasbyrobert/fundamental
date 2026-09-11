@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import CoreText
import Foundation

@MainActor
enum ShapingEvidence
{
    static func write(
        _ name: String, lines: [ExplicitShapedLine],
        extra: [String: Any] = [:]
    ) throws
    {
        var record = extra
        record["lines"] = try lines.map(describe)
        try PatternEvidence.write(name, group: "shaping", record: record)
    }

    static func describe(_ line: ExplicitShapedLine) throws -> [String: Any]
    {
        [
            "sourceUTF16": line.display.slice.source.source.utf16,
            "sourceRuns": try JSONSerialization.jsonObject(
                with: JSONEncoder().encode(
                    line.display.slice.source.paragraph.runs
                )
            ),
            "slice": ExplicitEvidence.describe(line.display.slice),
            "displayUTF16": line.display.units,
            "intervals": line.display.intervals.map
            {
                [
                    "display": [$0.range.lowerBound, $0.range.upperBound],
                    "kind": $0.atom.kind.rawValue,
                    "source": ExplicitEvidence.describe($0.atom.fragment)
                ] as [String: Any]
            },
            "inlineOffset": line.measurement.inlineOffset,
            "advance": line.measurement.advance,
            "trailingWhitespace": line.measurement.trailingWhitespace,
            "nativeRuns": line.runs.map(describe)
        ]
    }

    static func matrix(_ value: CGAffineTransform) -> [Double]
    {
        [value.a, value.b, value.c, value.d, value.tx, value.ty]
    }
}
