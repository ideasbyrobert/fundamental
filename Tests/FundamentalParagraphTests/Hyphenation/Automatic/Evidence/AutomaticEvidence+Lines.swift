@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import Foundation

extension AutomaticEvidence
{
    static func describe(_ line: HyphenatedShapedLine) -> [String: Any]
    {
        let suffix: [String: Any]
        switch line.display.suffix
        {
        case .none:
            suffix = ["kind": "none"]
        case let .automatic(ink):
            suffix = ["kind": "automatic", "ink": describe(ink)]
        }
        return [
            "body": ExplicitEvidence.describe(line.display.body.slice),
            "displayUTF16": line.display.units,
            "suffix": suffix,
            "advance": line.measurement.advance,
            "trailingWhitespace": line.measurement.trailingWhitespace,
            "inlineOffset": line.measurement.inlineOffset,
            "runs": line.runs.map
            {
                run in
                [
                    "raw": run.signature,
                    "range": [run.range.lowerBound, run.range.upperBound],
                    "fontUnique": run.font.unique,
                    "fontVersion": run.font.version,
                    "fontTraits": run.font.symbolicTraits,
                    "fontVariations": run.font.variations,
                    "fontMatrix": ShapingEvidence.matrix(run.font.matrix),
                    "matrix": ShapingEvidence.matrix(run.matrix),
                    "status": run.status,
                    "mappings": run.glyphs.map
                    {
                        [
                            "display": [
                                $0.displayRange.lowerBound,
                                $0.displayRange.upperBound
                            ],
                            "sources": $0.sources.map(describe)
                        ] as [String: Any]
                    }
                ] as [String: Any]
            }
        ]
    }
}
