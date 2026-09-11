@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import Foundation

@MainActor
enum AutomaticEvidence
{
    static func write(
        _ name: String, collection: ParagraphHyphens,
        lines: [HyphenatedShapedLine], extra: [String: Any] = [:]
    ) throws
    {
        var record = extra
        record["inkPolicyVersion"] = ParagraphHyphens.inkPolicyVersion
        record["sourceUTF16"] = collection.source.source.utf16
        record["sourceRuns"] = try JSONSerialization.jsonObject(
            with: JSONEncoder().encode(collection.source.paragraph.runs)
        )
        record["inks"] = collection.inks.map(describe)
        record["ownedRecords"] = collection.automatic.records.map
        {
            [
                "resolution": WordEvidence.describe($0.word.resolution),
                "flags": $0.word.flags,
                "outcome": OwnedEvidence.describe($0.outcome)
            ] as [String: Any]
        }
        record["lines"] = lines.map(describe)
        try PatternEvidence.write(name, group: "automatic-ink", record: record)
    }

    static func describe(_ ink: AutomaticHyphenInk) -> [String: Any]
    {
        [
            "word": ink.wordIndex, "candidate": ink.candidateIndex,
            "source": [
                ink.sourceRange.lowerBound, ink.sourceRange.upperBound
            ],
            "lookup": ink.candidate.lookupOffset,
            "scalar": ink.candidate.hyphenScalar,
            "character": [ink.character.lowerBound, ink.character.upperBound],
            "context": ink.context.map(ExplicitEvidence.describe),
            "styleOrigin": ExplicitEvidence.describe(ink.styleOrigin)
        ]
    }

    static func describe(_ value: HyphenatedGlyphSource) -> [String: Any]
    {
        switch value
        {
        case let .source(atom):
            [
                "kind": atom.kind.rawValue,
                "fragment": ExplicitEvidence.describe(atom.fragment)
            ]
        case let .generated(ink):
            ["kind": "generated", "ink": describe(ink)]
        }
    }
}
