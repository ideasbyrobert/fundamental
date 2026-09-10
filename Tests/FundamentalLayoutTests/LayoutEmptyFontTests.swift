import Testing

@testable import FundamentalLayout

@Suite("Chosen-font empty source layout")
struct LayoutEmptyFontTests
{
    @MainActor
    @Test("empty semantic forms retain nonempty native font geometry")
    func roleGeometry() throws
    {
        let native = NativeTextKit2Layout()
        let reference = try LayoutEmptyFontFixture.blocks([
            LayoutFixture.direct("Ag")
        ])
        for runs in try LayoutEmptyFontFixture.emptyRuns()
        {
            let blocks = try LayoutEmptyFontFixture.blocks(runs)
            for (block, referenceBlock) in zip(blocks, reference)
            {
                for width in [120.0, 240]
                {
                    let request = try LayoutFixture.request(width: width)
                    let snapshot = try native.layout(
                        LayoutFixture.projection([block]), request: request
                    )
                    let referenceSnapshot = try native.layout(
                        LayoutFixture.projection([referenceBlock]),
                        request: request
                    )
                    guard case let .lines(fragment) = snapshot.firstFragment,
                          case let .lines(sample) =
                            referenceSnapshot.firstFragment
                    else
                    {
                        Issue.record("Expected semantic line fragments")
                        continue
                    }
                    let line = fragment.line
                    #expect(snapshot.fragments.count == 1)
                    #expect(fragment.role == sample.role)
                    #expect(line.frame.size.height
                        == sample.line.frame.size.height)
                    #expect(line.baseline == sample.line.baseline)
                    #expect(line.defaultFont == sample.line.defaultFont)
                    #expect(line.frame.size.width == 0)
                    #expect(line.text == "")
                    #expect(line.sourceSlices == [])
                    #expect(line.glyphRuns == [])
                    #expect(line.caretStops.count == 1)
                    #expect(line.firstCaretStop.position == line.baseline)
                    #expect(line.firstCaretStop.utf16Offset == 0)
                    #expect(line.firstCaretStop.sourcePoint == .block(
                        blockID: LayoutFixture.blockID(0), utf16Offset: 0
                    ))
                    #expect(fragment.frame.size.width == width)
                    #expect(snapshot.size.height == line.frame.size.height)
                }
            }
        }
    }
}
