@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import AppKit
import Foundation

@MainActor
enum ParagraphEvidence
{
    static func score(_ value: ParagraphScore) -> [String: Any]
    {
        [
            "emergency": value.emergency, "ragged": value.ragged,
            "demerits": value.demerits
        ]
    }

    static func point(_ value: ParagraphBreak) -> [String: Any]
    {
        [
            "position": value.position, "visibleEnd": value.visibleEnd,
            "kind": value.kind.rank, "hyphenated": value.hyphenated,
            "penalty": value.penalty, "terminal": value.terminal
        ]
    }

    static func write(
        _ name: String, result: ParagraphComposition
    ) throws
    {
        try PatternEvidence.write(name, group: "paragraph", record: [
            "sourceUTF16": result.collection.source.source.utf16,
            "runs": try JSONSerialization.jsonObject(
                with: JSONEncoder().encode(
                    result.collection.source.paragraph.runs
                )
            ),
            "width": result.width,
            "fonts": result.attributes.values.map
            {
                attributes in
                let font = attributes[.font] as! NSFont
                return [
                    "name": font.fontName, "size": font.pointSize
                ] as [String: Any]
            },
            "segments": result.segments.map
            {
                [
                    "source": [
                        $0.candidates.line.range.lowerBound,
                        $0.candidates.line.range.upperBound
                    ],
                    "breaks": $0.candidates.breaks.map(point),
                    "path": $0.path.nodes,
                    "score": score($0.path.score),
                    "statesRetained": $0.path.statesRetained,
                    "transitions": $0.path.transitions,
                    "nativeMeasurements": $0.nativeMeasurements,
                    "metricRequests": $0.metricRequests,
                    "lines": $0.lines.map(describe)
                ] as [String: Any]
            }
        ])
    }
}
