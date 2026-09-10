import Testing

@testable import FundamentalProjection

@Suite("Validated immutable list position")
struct ProjectedListPositionTests
{
    @Test("indices retain count and a safe one-based number", arguments: [
        (0, 1, 1), (0, 100, 1), (98, 100, 99), (99, 100, 100),
        (Int.max - 1, Int.max, Int.max)
    ])
    func valid(_ value: (Int, Int, Int)) throws
    {
        let position = try #require(ProjectedListPosition(
            index: value.0, count: value.1
        ))
        #expect(position.index == value.0)
        #expect(position.count == value.1)
        #expect(position.number == value.2)
    }

    @Test("invalid or empty membership cannot form a position", arguments: [
        (-1, 1), (0, 0), (0, -1), (1, 1), (Int.max, Int.max),
        (Int.min, Int.max)
    ])
    func invalid(_ value: (Int, Int))
    {
        #expect(ProjectedListPosition(index: value.0, count: value.1) == nil)
    }
}
