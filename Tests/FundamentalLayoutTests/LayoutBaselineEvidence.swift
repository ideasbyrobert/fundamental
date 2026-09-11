import Foundation

@testable import FundamentalLayout

@MainActor
enum LayoutBaselineEvidence
{
    static func write(_ fixture: LayoutBaselineFixture) throws
    {
        guard let path = ProcessInfo.processInfo.environment[
            "FUNDAMENTAL_LAYOUT_MARKER_CAPTURE_DIR"
        ]
        else
        {
            return
        }
        let root = URL(fileURLWithPath: path)
        try FileManager.default.createDirectory(
            at: root, withIntermediateDirectories: true
        )
        let record: [String: Any] = [
            "text": fixture.attributed.string,
            "runs": fixture.runs.map
            {
                [
                    "font": String(describing: $0.font),
                    "source": $0.sourceSlices.map(String.init(describing:)),
                    "style": String(describing: $0.style),
                    "decorations": $0.decorations.map(String.init(describing:)),
                    "glyphs": $0.glyphs.map
                    {
                        [
                            "identifier": $0.identifier,
                            "position": [$0.position.x, $0.position.y],
                            "advance": [$0.advance.dx, $0.advance.dy],
                            "source": $0.sourceSlices.map(
                                String.init(describing:)
                            )
                        ] as [String: Any]
                    }
                ] as [String: Any]
            },
            "lines": fixture.publicLines.map(structure)
        ]
        try JSONSerialization.data(
            withJSONObject: record, options: [.prettyPrinted, .sortedKeys]
        ).write(to: root.appendingPathComponent("baseline-" + fixture.name
                                                + ".json"))
    }

    static func structure(_ line: LayoutLine) -> [String: Any]
    {
        [
            "text": line.text,
            "frame": String(describing: line.frame),
            "baseline": [line.baseline.x, line.baseline.y],
            "selectionExtent": String(describing: line.selectionExtent),
            "source": line.sourceSlices.map(String.init(describing:)),
            "carets": line.caretStops.map(String.init(describing:)),
            "decorations": line.glyphRuns.flatMap(\.decorations)
                .map(String.init(describing:))
        ]
    }
}
