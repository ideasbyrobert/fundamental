import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutListLineTests
{
    @MainActor
    @Test("owned list lines reproduce native source and marker pixels")
    func nativeListPixels() throws
    {
        let samples = [
            "empty": "", "embedded": "First\nSecond",
            "unicode": "Readable e\u{301}😀 Раздел continues on another line.",
            "bidi": "First שלום 123 last", "rtl": "שלום עולם"
        ]
        for kind in SemanticListKind.allCases
        {
            for name in samples.keys.sorted()
            {
                let text = try #require(samples[name])
                let lines = try LayoutListLineFixture.lines(
                    kind, number: 100, count: 100,
                    runs: [LayoutFixture.direct(text)], width: 240
                )
                let first = try #require(lines.first)
                let marker = try #require(first.marker)
                let inset = try LayoutListRasterFixture.sourceInset(marker)
                let height = try #require(lines.map(\.frame.maxY).max())
                let fixture = try LayoutListRasterFixture(
                    text: text, width: 240 - inset
                )
                for scale in [1.0, 2]
                {
                    let expected = try fixture.image(
                        width: 240, height: height, scale: scale
                    )
                    {
                        fixture.expected(in: $0, inset: inset, marker: marker)
                    }
                    let actual = try fixture.image(
                        width: 240, height: height, scale: scale
                    )
                    {
                        try fixture.actual(lines, in: $0)
                    }
                    let a = try #require(actual.dataProvider?.data) as Data
                    let b = try #require(expected.dataProvider?.data) as Data
                    #expect(a == b, "\(kind) \(name) at \(scale)x")
                    if scale == 2
                    {
                        let label = "list-\(kind)-\(name)"
                        try LayoutMarkerRasterFixture.capture(
                            expected, name: label + "-native"
                        )
                        try LayoutMarkerRasterFixture.capture(
                            actual, name: label + "-owned"
                        )
                    }
                }
            }
        }
    }
}
