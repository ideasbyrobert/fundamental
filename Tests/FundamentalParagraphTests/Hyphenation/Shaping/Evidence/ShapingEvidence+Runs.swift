@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import Foundation

extension ShapingEvidence
{
    static func describe(_ run: MappedNativeRun<ExplicitDisplayAtom>)
        -> [String: Any]
    {
        [
            "range": [run.range.lowerBound, run.range.upperBound],
            "font": [
                "postScript": run.font.postScript,
                "unique": run.font.unique, "version": run.font.version,
                "pointSize": run.font.pointSize,
                "symbolicTraits": run.font.symbolicTraits,
                "matrix": matrix(run.font.matrix),
                "variations": run.font.variations
            ],
            "matrix": matrix(run.matrix), "status": run.status,
            "glyphs": run.glyphs.map
            {
                [
                    "id": $0.identifier,
                    "position": [$0.position.x, $0.position.y],
                    "advance": [$0.advance.width, $0.advance.height],
                    "index": $0.stringIndex,
                    "display": [
                        $0.displayRange.lowerBound, $0.displayRange.upperBound
                    ],
                    "sources": $0.sources.map
                    {
                        [
                            "kind": $0.kind.rawValue,
                            "fragment": ExplicitEvidence.describe($0.fragment)
                        ]
                    }
                ] as [String: Any]
            }
        ]
    }
}
