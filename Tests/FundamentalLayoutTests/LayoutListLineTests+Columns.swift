import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutListLineTests
{
    @MainActor
    @Test("run count reserves a stable column through decimal transitions")
    func columns() throws
    {
        for kind in SemanticListKind.allCases
        {
            var insets: [Double] = []
            for count in [1, 9, 10, 99, 100, 999, 10_000, Int.max]
            {
                var columns: [Double] = []
                for number in Set([1, min(4, count), count]).sorted()
                {
                    let lines = try LayoutListLineFixture.lines(
                        kind, number: number, count: count,
                        runs: [LayoutFixture.direct(
                            "Source\ncontinues on\nthe next line."
                        )], width: 420
                    )
                    #expect(lines.count > 1)
                    let first = try #require(lines.first)
                    let marker = try #require(first.marker)
                    let column = marker.baseline.x + marker.advance
                    columns.append(column)
                    #expect(marker.inkBounds.minX >= 0)
                    #expect(marker.inkBounds.maxX <= column)
                    #expect(column < first.baseline.x)
                    #expect(lines.allSatisfy
                    {
                        $0.baseline.x == first.baseline.x
                            && $0.firstCaretStop.position.x == first.baseline.x
                            && $0.frame.maxX <= 420
                    })
                    #expect(lines.dropFirst().allSatisfy { $0.marker == nil })
                    if number == 1
                    {
                        insets.append(first.baseline.x)
                    }
                }
                #expect(Set(columns).count == 1)
            }
            if kind == .bulleted
            {
                #expect(Set(insets).count == 1)
            }
            else
            {
                #expect(insets[0] == insets[1])
                #expect(insets[2] == insets[3])
                #expect(insets[4] == insets[5])
                #expect(insets[1] < insets[2])
                #expect(insets[3] < insets[4])
                #expect(insets[5] < insets[6])
                #expect(insets[6] < insets[7])
            }
        }
    }
}
