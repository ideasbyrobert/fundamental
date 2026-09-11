import FundamentalNativeParagraph

@MainActor
enum ComposerDrawingEvidence
{
    static func describe(_ plan: ParagraphPlannedLine) throws -> [String: Any]
    {
        let line = try SpacedNativeLine(plan)
        try SpacingAssertions.geometry(line)
        let raster = try SpacingFixture.raster(line)
        SpacingAssertions.unclipped(
            raster, empty: plan.shaped.display.units.isEmpty
        )
        return [
            "plan": ParagraphEvidence.describe(plan),
            "raster": SpacingEvidence.describe(raster)
        ]
    }

    static func write(
        _ name: String, paragraph: ParagraphComposition
    ) throws
    {
        try PatternEvidence.write(name, group: "composer-drawing", record: [
            "sourceUTF16": paragraph.collection.source.source.utf16,
            "width": paragraph.width,
            "segments": try paragraph.segments.map
            {
                [
                    "path": $0.path.nodes,
                    "lines": try $0.lines.map(describe)
                ] as [String: Any]
            }
        ])
    }
}
