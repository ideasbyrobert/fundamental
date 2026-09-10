import Testing

@testable import FundamentalLayout

extension LayoutSelectionExtentTests
{
    @Test("aligning text retains the independently placed container")
    func alignedContainer() throws
    {
        let lines = try LayoutListLineFixture.lines(
            .bulleted, runs: [LayoutFixture.direct("A\n")], width: 240
        )
        let source = try #require(lines.first)
        let moved = try NativeTextKit2Layout().translated(
            source, dx: 32.5, dy: 8, containerDX: 12
        )
        #expect(moved.frame.minX == source.frame.minX + 32.5)
        #expect(moved.selectionExtent.leading
            == source.selectionExtent.leading + 12)
        #expect(moved.selectionExtent.trailing
            == source.selectionExtent.trailing + 12)
        #expect(moved.sourceSlices == source.sourceSlices)
    }
}
