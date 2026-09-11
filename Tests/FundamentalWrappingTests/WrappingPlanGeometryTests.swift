import Testing

@testable import FundamentalWrapping

@Suite("Finite feasible visual line measures")
struct WrappingPlanGeometryTests
{
    @Test("nonpositive and nonfinite available widths fail",
          arguments: [0, -0.0, -1, Double.nan, .infinity, -.infinity])
    func width(_ width: Double)
    {
        #expect(WrappingPlan(
            source: WrappingSource("a"), width: width,
            lines: [WrappingPlanFixture.line(0 ..< 1)]
        ) == nil)
    }

    @Test("invalid indentation, advance and exhausted width fail",
          arguments: [
              (-1.0, 0.0), (Double.nan, 0), (.infinity, 0), (-.infinity, 0),
              (100, 0), (101, 0), (.greatestFiniteMagnitude, 0),
              (0, -1), (0, .nan), (0, .infinity), (0, -.infinity),
              (0, 101), (20, 80.0.nextUp), (99, 2)
          ])
    func geometry(_ indentation: Double, advance: Double)
    {
        let line = WrappingPlanFixture.line(
            0 ..< 1, indentation: indentation, advance: advance
        )
        #expect(WrappingPlan(
            source: WrappingSource("a"), width: 100, lines: [line]
        ) == nil)
    }

    @Test("each continuation must fit, not only the first line")
    func continuation()
    {
        let lines = [
            WrappingPlanFixture.line(0 ..< 1, .soft, advance: 50),
            WrappingPlanFixture.line(1 ..< 2, indentation: 25, advance: 76)
        ]
        #expect(WrappingPlan(
            source: WrappingSource("ab"), width: 100, lines: lines
        ) == nil)
    }

    @Test("exact fit and smaller advances preserve supplied measures",
          arguments: [0.0, 40, 80])
    func exactFit(_ advance: Double) throws
    {
        let line = WrappingPlanFixture.line(
            0 ..< 1, indentation: 20, advance: advance
        )
        let plan = try #require(WrappingPlan(
            source: WrappingSource("a"), width: 100, lines: [line]
        ))
        #expect(plan.lines.first?.advance == advance)
        #expect(plan.lines.first?.indentation == 20)
    }
}
