@testable import FundamentalWrapping

enum WrappingPlanFixture
{
    static func line(
        _ range: Range<Int>, _ kind: WrappingLineBreak = .end,
        indentation: Double = 0, advance: Double = 0
    ) -> WrappingLineChoice
    {
        WrappingLineChoice(
            range: range, indentation: indentation, advance: advance,
            breakKind: kind
        )
    }
}
