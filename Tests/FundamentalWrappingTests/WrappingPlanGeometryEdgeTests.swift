import Testing

@testable import FundamentalWrapping

@Suite("Visual measure numerical edges")
struct WrappingPlanGeometryEdgeTests
{
    @Test("signed zero is normalized without erasing zero-width content")
    func signedZero() throws
    {
        let line = WrappingPlanFixture.line(
            0 ..< 3, indentation: -0.0, advance: -0.0
        )
        let plan = try #require(WrappingPlan(
            source: WrappingSource("\u{AD}\u{200B}\u{2060}"), width: 100,
            lines: [line]
        ))
        let accepted = try #require(plan.lines.first)
        #expect(accepted.indentation.bitPattern == Double(0).bitPattern)
        #expect(accepted.advance.bitPattern == Double(0).bitPattern)
        #expect(plan.source.utf16 == [173, 8203, 8288])
    }

    @Test("extreme finite measures use the remaining width safely")
    func finiteExtremes() throws
    {
        let width = Double.greatestFiniteMagnitude
        let half = width / 2
        let line = WrappingPlanFixture.line(
            0 ..< 1, indentation: half, advance: half
        )
        let plan = try #require(WrappingPlan(
            source: WrappingSource("a"), width: width, lines: [line]
        ))
        #expect(plan.width == width)
        let overflow = WrappingPlanFixture.line(
            0 ..< 1, indentation: half, advance: width
        )
        #expect(WrappingPlan(
            source: plan.source, width: width, lines: [overflow]
        ) == nil)
        #expect(WrappingPlan(
            source: WrappingSource(""), width: .leastNonzeroMagnitude,
            lines: [WrappingPlanFixture.line(0 ..< 0)]
        ) != nil)
    }
}
