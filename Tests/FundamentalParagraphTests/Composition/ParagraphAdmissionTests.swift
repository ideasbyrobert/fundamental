@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import AppKit
import Testing

@MainActor
struct ParagraphAdmissionTests
{
    @Test func invalidMeasuresFailBeforeResolvingFonts() throws
    {
        let collection = try AutomaticFixture.text("aa bb")
        let cache = try ParagraphFixture.cache(collection)
        var resolved = 0
        for width in [0, -1, Double.nan, .infinity, -.infinity]
        {
            #expect(throws: ParagraphFailure.invalidWidth)
            {
                try ParagraphComposition(legacy:collection, width: width)
                {
                    resolved += 1
                    return try ShapingFixture.attributes($0, size: 18)
                }
            }
            #expect(throws: ParagraphFailure.invalidWidth)
            {
                try LegacyParagraphOptimizer(
                    cache: cache, width: width
                ).optimize()
            }
        }
        #expect(resolved == 0)
        #expect(cache.nativeMeasurements == 0)
        try PatternEvidence.write(
            "dimensions", group: "paragraph-controls",
            record: ["refusals": 10, "fontCalls": resolved]
        )
    }

    @Test func fontSnapshotRejectsMissingMutableAndChangedSource() throws
    {
        let source = try ExplicitFixture.source("aa")
        #expect(throws: ParagraphFailure.missingFont)
        {
            try ParagraphAttributes(source) { _ in [:] }
        }
        #expect(throws: ParagraphFailure.mutableStyle)
        {
            try ParagraphAttributes(source)
            {
                var attributes = try ShapingFixture.attributes($0, size: 18)
                attributes[.paragraphStyle] = NSMutableParagraphStyle()
                return attributes
            }
        }
        let attributes = try ParagraphAttributes(source)
        {
            try ShapingFixture.attributes($0, size: 18)
        }
        let other = try AutomaticFixture.text("bb")
        let display = try HyphenatedDisplay(
            other, range: 0..<2, end: .unbroken
        )
        #expect(throws: ParagraphFailure.changedSource)
        {
            try attributes.attributed(display)
        }
    }

    @Test func oversizedCompleteCharacterIsAnExplicitRefusal() throws
    {
        let value = try AutomaticFixture.text("👩‍💻")
        let cache = try ParagraphFixture.cache(value)
        #expect(cache.candidates.breaks.count == 2)
        #expect(throws: ParagraphFailure.noFeasibleLayout(0..<5))
        {
            try ParagraphFixture.compose(value, width: 1)
        }
        try PatternEvidence.write("unfittable", group: "paragraph-controls",
                                  record: ["sourceUTF16": [55357, 56425, 8205,
                                                           55357, 56507],
                                           "width": 1, "emergencyPoints": 0])
    }
}
