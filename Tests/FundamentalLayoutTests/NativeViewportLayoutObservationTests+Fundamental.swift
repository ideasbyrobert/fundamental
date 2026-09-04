import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension NativeViewportLayoutObservationTests
{
    @MainActor
    @Test("eager rich geometry grows with the complete block collection")
    func eagerRetention() throws
    {
        let short = try Self.eagerLayout(blockCount: 8)
        let long = try Self.eagerLayout(blockCount: 80)
        #expect(long.fragments.count > short.fragments.count * 9)
        #expect(Self.glyphCount(long) > Self.glyphCount(short) * 9)
        #expect(Self.caretCount(long) > Self.caretCount(short) * 9)
        #expect(Self.sliceCount(long) > Self.sliceCount(short) * 9)
    }

    @MainActor
    @Test("eager layout retains a rich fragment for every source block")
    func eagerSourceCoverage() throws
    {
        let snapshot = try Self.eagerLayout(blockCount: 80)
        let blockIDs = Set(snapshot.fragments.map
        {
            $0.source.blockID
        })
        #expect(blockIDs.count == 80)
        #expect(snapshot.fragments.count >= blockIDs.count)
    }

    @MainActor
    private static func eagerLayout(
        blockCount: Int
    ) throws -> LayoutSnapshot
    {
        let blocks = (0 ..< blockCount).map
        {
            _ in
            SemanticBlock.paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct("Finite native construction evidence.")
            ]))
        }
        return try NativeTextKit2Layout().layout(
            LayoutFixture.projection(blocks),
            request: LayoutFixture.request(width: 400)
        )
    }

    private static func glyphCount(_ snapshot: LayoutSnapshot) -> Int
    {
        lines(snapshot).flatMap(\.glyphRuns).flatMap(\.glyphs).count
    }

    private static func caretCount(_ snapshot: LayoutSnapshot) -> Int
    {
        lines(snapshot).reduce(0)
        {
            $0 + $1.caretStops.count
        }
    }

    private static func sliceCount(_ snapshot: LayoutSnapshot) -> Int
    {
        lines(snapshot).reduce(0)
        {
            $0 + $1.sourceSlices.count
        }
    }

    private static func lines(_ snapshot: LayoutSnapshot) -> [LayoutLine]
    {
        snapshot.fragments.compactMap
        {
            guard case let .lines(fragment) = $0
            else
            {
                return nil
            }
            return fragment.line
        }
    }
}
