import FundamentalNativeParagraph

extension LayoutProseCapture
{
    static func line(_ value: ParagraphPlannedLine) throws -> [String: Any]
    {
        let spaced = try SpacedNativeLine(value)
        return [
            "sourceRange": range(value.sourceRange),
            "tail": value.tail.map(fragment),
            "display": value.shaped.display.text,
            "advance": spaced.advance,
            "adjustment": value.spacing.adjustment,
            "spacing": value.spacing.kind.rawValue,
            "runs": spaced.runs.map
            {
                run in
                [
                    "range": range(run.original.range),
                    "font": run.original.font.postScript,
                    "fontVersion": run.original.font.version,
                    "fontSize": run.original.font.pointSize,
                    "baseline": run.baseline,
                    "glyphs": run.glyphs.map
                    {
                        glyph in
                        [
                            "id": glyph.original.identifier,
                            "position": [glyph.position.x, glyph.position.y],
                            "advance": [
                                glyph.advance.width, glyph.advance.height
                            ],
                            "displayRange": range(glyph.original.displayRange),
                            "sources": glyph.original.sources.map(source)
                        ] as [String: Any]
                    },
                    "decorations": run.decorations.map
                    {
                        [
                            "kind": $0.kind.rawValue,
                            "bounds": [
                                $0.bounds.minX, $0.bounds.minY,
                                $0.bounds.width, $0.bounds.height
                            ],
                            "sources": $0.sources.map(source)
                        ] as [String: Any]
                    }
                ] as [String: Any]
            }
        ]
    }
}
