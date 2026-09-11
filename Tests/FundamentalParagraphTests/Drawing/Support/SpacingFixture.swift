@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import AppKit
import Testing

@MainActor
enum SpacingFixture
{
    static let origin = CGPoint(x: 32, y: 48)

    static func plan(
        _ shaped: HyphenatedShapedLine, amount: Double
    ) throws -> ParagraphPlannedLine
    {
        let metrics = try ParagraphLineMetrics(
            shaped.measurement, units: shaped.display.units
        )
        let width = metrics.advance + Double(metrics.gaps.count) * amount
        let ratio = amount == 0 ? 0
            : amount / (try #require(metrics.gaps.map(\.advance).min())
                * (amount > 0 ? 0.75 : 0.25))
        return ParagraphPlannedLine(
            sourceRange: shaped.display.body.slice.range, tail: [],
            ending: ParagraphBreak(
                position: shaped.display.body.slice.range.upperBound,
                visibleEnd: shaped.display.body.slice.range.upperBound,
                kind: .terminal(.end)
            ),
            shaped: shaped, metrics: metrics,
            spacing: ParagraphSpacing(
                kind: amount == 0 ? .natural : .justified,
                adjustment: amount, advance: width, ratio: ratio,
                fitness: ParagraphFitness(ratio: ratio)
            )
        )
    }

    static func text(
        _ text: String, amount: Double = 0, size: Double = 18
    ) throws -> SpacedNativeLine
    {
        let collection = try AutomaticFixture.text(text)
        return try SpacedNativeLine(plan(
            AutomaticFixture.line(
                collection, range: 0..<text.utf16.count, size: size
            ),
            amount: amount
        ))
    }

    static func raster(
        _ line: SpacedNativeLine, scale: Double = 2
    ) throws -> SpacingRaster
    {
        try SpacingRaster(
            width: max(line.advance, line.plan.metrics.advance) + 64,
            height: 128, scale: scale
        )
        {
            line.draw(in: $0, origin: origin, ink: CGColor(gray: 0, alpha: 1))
        }
    }
}
