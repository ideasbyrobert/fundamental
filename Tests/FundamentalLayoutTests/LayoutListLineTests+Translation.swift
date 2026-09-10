import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutListLineTests
{
    @MainActor
    @Test("source and generated geometry translate together without new text")
    func translation() throws
    {
        let native = NativeTextKit2Layout()
        for kind in SemanticListKind.allCases
        {
            let lines = try LayoutListLineFixture.lines(kind, runs: [
                LayoutFixture.direct("First line\nSecond line")
            ])
            for line in lines
            {
                let moved = try native.translated(line, dx: 17.25, dy: 43.5)
                #expect(try native.translated(
                    moved, dx: -17.25, dy: -43.5
                ) == line)
                #expect(moved.text == line.text)
                #expect(moved.sourceSlices == line.sourceSlices)
                #expect(moved.caretStops.map(\.sourcePoint)
                    == line.caretStops.map(\.sourcePoint))
                if let marker = line.marker
                {
                    let translated = try #require(moved.marker)
                    #expect(translated.source == marker.source)
                    #expect(translated.advance == marker.advance)
                    #expect(translated.inkBounds.minX
                        == marker.inkBounds.minX + 17.25)
                    #expect(translated.baseline.y == marker.baseline.y + 43.5)
                    #expect(translated.glyphRuns.map(\.font)
                        == marker.glyphRuns.map(\.font))
                }
                else
                {
                    #expect(moved.marker == nil)
                }
            }
            for invalid in [Double.nan, .infinity, -.infinity]
            {
                #expect(throws: LayoutFailure.nonfiniteNativeGeometry)
                {
                    try native.translated(lines[0], dx: invalid, dy: 0)
                }
                #expect(throws: LayoutFailure.nonfiniteNativeGeometry)
                {
                    try native.translated(lines[0], dx: 0, dy: invalid)
                }
            }
        }
    }
}
