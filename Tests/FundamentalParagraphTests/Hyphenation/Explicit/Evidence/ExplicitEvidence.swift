@testable import FundamentalParagraph
import Foundation

enum ExplicitEvidence
{
    static func write(
        _ name: String, collection: ExplicitParagraphHyphens,
        slices: [ExplicitDisplaySlice] = []
    ) throws
    {
        let source = collection.source
        try PatternEvidence.write(name, group: "explicit", record: [
            "policyVersion": ExplicitParagraphHyphens.policyVersion,
            "sourceUTF16": source.source.utf16,
            "runs": try JSONSerialization.jsonObject(
                with: JSONEncoder().encode(source.paragraph.runs)
            ),
            "marks": collection.marks.map(describe),
            "groups": collection.groups.map
            {
                [
                    "range": [$0.range.lowerBound, $0.range.upperBound],
                    "marks": $0.marks.map(describe),
                    "resolution": WordEvidence.describe($0.resolution)
                ] as [String: Any]
            },
            "records": collection.records.map
            {
                [
                    "group": $0.groupIndex,
                    "mark": describe($0.mark),
                    "outcome": describe($0.outcome)
                ] as [String: Any]
            },
            "slices": slices.map(describe)
        ])
    }

    static func describe(_ mark: SourceHyphenationMark) -> [String: Any]
    {
        [
            "scalar": mark.mark.rawValue,
            "range": [mark.range.lowerBound, mark.range.upperBound]
        ]
    }

    static func describe(_ fragment: WordRunFragment) -> [String: Any]
    {
        [
            "run": fragment.runIndex,
            "paragraph": [
                fragment.paragraphRange.lowerBound,
                fragment.paragraphRange.upperBound
            ],
            "local": [
                fragment.runRange.lowerBound, fragment.runRange.upperBound
            ]
        ]
    }
}
