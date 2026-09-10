import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutListLineTests
{
    @MainActor
    @Test("insufficient source width refuses without clipping")
    func narrowRefusal() throws
    {
        for kind in SemanticListKind.allCases
        {
            let empty = try LayoutListLineFixture.lines(kind, runs: [])
            let inset = try #require(empty.first).baseline.x
            for width in [0, inset - 0.01, inset]
            {
                #expect(throws: LayoutFailure.unrepresentableListGeometry)
                {
                    try LayoutListLineFixture.lines(
                        kind, runs: [], width: width
                    )
                }
            }
            #expect(try LayoutListLineFixture.lines(
                kind, runs: [], width: inset + 0.01
            ).count == 1)
            #expect(throws: LayoutFailure.unrepresentableListGeometry)
            {
                try LayoutListLineFixture.lines(
                    kind, runs: [LayoutFixture.direct("😀")],
                    width: inset + 1
                )
            }
            for width in [Double.nan, .infinity, -.infinity]
            {
                #expect(throws: LayoutFailure.nonfiniteNativeGeometry)
                {
                    try LayoutListLineFixture.lines(
                        kind, runs: [], width: width
                    )
                }
            }
        }
    }

    @MainActor
    @Test("native trailing-space carets cannot silently escape the measure")
    func trailingSpaceRefusal() throws
    {
        #expect(throws: LayoutFailure.unrepresentableListGeometry)
        {
            try LayoutListLineFixture.lines(
                .numbered, count: 100, runs: [LayoutFixture.direct(String(
                    repeating: "Source continues on the next line. ", count: 8
                ))], width: 420
            )
        }
    }
}
