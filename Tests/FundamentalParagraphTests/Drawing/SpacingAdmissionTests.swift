@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import AppKit
import Testing

@MainActor
struct SpacingAdmissionTests
{
    @Test func inconsistentAndOutOfBoundsPlansAreRefused() throws
    {
        let collection = try AutomaticFixture.text("a b")
        let shaped = try AutomaticFixture.line(collection, range: 0..<3)
        #expect(throws: NativeSpacingFailure.invalidPlan)
        {
            try SpacedNativeLine(SpacingFixture.plan(shaped, amount: 10))
        }
        let plan = try SpacingFixture.plan(shaped, amount: 0)
        let changed = ParagraphPlannedLine(
            sourceRange: plan.sourceRange, tail: plan.tail, ending: plan.ending,
            shaped: shaped,
            metrics: .init(advance: plan.metrics.advance + 1, gapWidths: []),
            spacing: plan.spacing
        )
        #expect(throws: NativeSpacingFailure.changedMetrics)
        {
            try SpacedNativeLine(changed)
        }
        try PatternEvidence.write("plans", group: "spacing-controls",
                                  record: ["refusals": 2])
    }

    @Test func unsupportedDirectionAndDecorationAreExplicit() throws
    {
        #expect(throws: NativeSpacingFailure.unsupportedDirection)
        {
            try SpacingFixture.text("אבג")
        }
        let value = try AutomaticFixture.text("a b")
        let shaped = try HyphenatedShapedLine(value, range: 0..<3)
        {
            var attributes = try ShapingFixture.attributes($0, size: 18)
            attributes[.underlineStyle] = NSUnderlineStyle.double.rawValue
            return attributes
        }
        #expect(throws: NativeSpacingFailure.unsupportedDecoration)
        {
            try SpacedNativeLine(SpacingFixture.plan(shaped, amount: 0))
        }
        try PatternEvidence.write("unsupported", group: "spacing-controls",
                                  record: ["refusals": 2])
    }

    @Test func ambiguousOrRepeatedGapGlyphsAreRefused() throws
    {
        let line = try SpacingFixture.text("a b", amount: 2)
        let old = try #require(line.runs.first?.glyphs.first?.original)
        let adjustments = try SpacingAdjustments(line.plan)
        let invalid = MappedNativeGlyph(
            identifier: old.identifier, position: old.position,
            advance: old.advance, stringIndex: 0, displayRange: 0..<3,
            sources: old.sources
        )
        var gaps: Set<Int> = []
        #expect(throws: NativeSpacingFailure.ambiguousGap)
        {
            try SpacedNativeGlyph(
                invalid, adjustments: adjustments, gaps: &gaps
            )
        }
        let space = try #require(line.runs.flatMap(\.glyphs).first
        {
            $0.original.stringIndex == 1
        })
        gaps = [1]
        #expect(throws: NativeSpacingFailure.ambiguousGap)
        {
            try SpacedNativeGlyph(
                space.original, adjustments: adjustments, gaps: &gaps
            )
        }
        try PatternEvidence.write("gaps", group: "spacing-controls",
                                  record: ["refusals": 2])
    }
}
