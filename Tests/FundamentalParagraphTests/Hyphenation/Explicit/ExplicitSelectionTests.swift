@testable import FundamentalParagraph
import Testing

@Suite
struct ExplicitSelectionTests
{
    @Test
    func invalidAndRefusedIndicesCannotCreateASelection() throws
    {
        let collection = ExplicitParagraphHyphens(
            try ExplicitFixture.source("a\u{AD}bc")
        )
        for index in [-1, 1, Int.max]
        {
            #expect(throws: ExplicitProjectionFailure.invalidSelection(index))
            {
                try collection.select(index)
            }
        }
        let refused = ExplicitParagraphHyphens(
            try ExplicitFixture.source("a\u{2011}bc")
        )
        #expect(throws: ExplicitProjectionFailure.refusedSelection(0))
        {
            try refused.select(0)
        }
        try PatternEvidence.write(
            "indices", group: "explicit-controls",
            record: ["invalid": [-1, 1, Int.max], "refused": 0]
        )
    }

    @Test
    func projectionEndAndMarkerCoverageMustMatchTheSelection() throws
    {
        let collection = ExplicitParagraphHyphens(
            try ExplicitFixture.source("a\u{AD}bc")
        )
        let selected = try collection.select(0)
        #expect(throws: ExplicitProjectionFailure.endMismatch)
        {
            try collection.project(0..<3, end: .opportunity(selected))
        }
        #expect(throws: ExplicitProjectionFailure.markerExcluded)
        {
            try collection.project(2..<2, end: .opportunity(selected))
        }
        for range in [-1..<2, 0..<5]
        {
            #expect(throws: ExplicitProjectionFailure.invalidRange(range))
            {
                try collection.project(range)
            }
        }
        let emoji = ExplicitParagraphHyphens(
            try ExplicitFixture.source("👩‍💻 a\u{AD}bc")
        )
        #expect(throws: ExplicitProjectionFailure.invalidRange(2..<8))
        {
            try emoji.project(2..<8)
        }
        try PatternEvidence.write(
            "ranges", group: "explicit-controls", record: [
                "wrongEnd": [0, 3], "excludedMarker": [2, 2],
                "invalidRanges": [[-1, 2], [0, 5], [2, 8]]
            ]
        )
    }
}
