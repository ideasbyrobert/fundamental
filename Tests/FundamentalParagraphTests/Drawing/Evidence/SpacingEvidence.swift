@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import CoreGraphics
import CryptoKit
import Foundation

@MainActor
enum SpacingEvidence
{
    static func rectangle(_ value: CGRect) -> [Double]
    {
        value.isNull ? [] : [
            value.minX, value.minY, value.width, value.height
        ]
    }

    static func write(
        _ name: String, line: SpacedNativeLine, raster: SpacingRaster
    ) throws
    {
        try SpacingCapture.write(
            raster, name: name, group: "spacing-images"
        )
        try PatternEvidence.write(name, group: "spacing", record: [
            "plan": ParagraphEvidence.describe(line.plan),
            "advance": line.advance, "inkBounds": rectangle(line.inkBounds),
            "raster": describe(raster),
            "runs": line.runs.map
            {
                [
                    "font": $0.original.font.postScript,
                    "baseline": $0.baseline,
                    "glyphs": $0.glyphs.map
                    {
                        [
                            "identifier": Int($0.original.identifier),
                            "display": [$0.original.displayRange.lowerBound,
                                        $0.original.displayRange.upperBound],
                            "position": [$0.position.x, $0.position.y],
                            "advance": [$0.advance.width, $0.advance.height]
                        ] as [String: Any]
                    },
                    "decorations": $0.decorations.map
                    {
                        [
                            "kind": $0.kind.rawValue,
                            "bounds": rectangle($0.bounds)
                        ] as [String: Any]
                    }
                ] as [String: Any]
            }
        ])
    }
}
