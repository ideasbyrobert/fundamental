@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Foundation
import Testing

@MainActor
enum StagedAssertions
{
    static func compare(
        _ name: String, original: ParagraphComposition, width: Double
    ) throws -> StagedParagraphComposition
    {
        let full = try TerminalComposition(original, width: width)
        let staged = try ComposerDirectFixture.compose(original, width: width)
        let replay = try StagedParagraphComposition(original, width: width)
        try ParagraphAssertions.verify(staged.paragraph)
        #expect(full.paths.count == staged.searches.count)
        var records: [[String: Any]] = []
        for (index, segment) in staged.paragraph.segments.enumerated()
        {
            let prior = full.paragraph.segments[index]
            let search = staged.searches[index]
            #expect(search.path.nodes == full.paths[index].nodes)
            #expect(search.path.score == full.paths[index].score)
            #expect(segment.path.score == prior.path.score)
            #expect(search.usedFallback == (search.path.score.emergency > 0))
            let lines = segment.lines.map(ParagraphEvidence.describe)
            #expect(try bytes(lines) == bytes(
                prior.lines.map(ParagraphEvidence.describe)
            ))
            let repeated = replay.paragraph.segments[index]
            #expect(try bytes(lines) == bytes(
                repeated.lines.map(ParagraphEvidence.describe)
            ))
            #expect(work(segment) == work(repeated))
            #expect(search.path.score == replay.searches[index].path.score)
            if search.usedFallback
            {
                #expect(segment.nativeMeasurements == prior.nativeMeasurements)
            }
            else
            {
                #expect(segment.nativeMeasurements <= prior.nativeMeasurements)
                #expect(segment.metricRequests <= prior.metricRequests)
            }
            records.append([
                "path": search.path.nodes,
                "score": ComposerEvidence.score(search.path.score),
                "lines": lines, "fallback": search.usedFallback,
                "fullWork": work(prior), "stagedWork": work(segment),
                "ordinaryMeasurements": search.ordinaryMeasurements,
                "ordinaryRequests": search.ordinaryRequests
            ])
        }
        try PatternEvidence.write(name, group: "composer", record: [
            "sourceUTF16": original.collection.source.source.utf16,
            "width": width, "segments": records
        ])
        try ComposerDrawingEvidence.write(name, paragraph: staged.paragraph)
        return staged
    }

    static func bytes(_ value: Any) throws -> Data
    {
        try JSONSerialization.data(
            withJSONObject: value, options: .sortedKeys
        )
    }

    static func work(_ segment: ParagraphSegmentPlan) -> [String: Int]
    {
        [
            "nativeMeasurements": segment.nativeMeasurements,
            "metricRequests": segment.metricRequests,
            "states": segment.path.statesRetained,
            "transitions": segment.path.transitions
        ]
    }
}
