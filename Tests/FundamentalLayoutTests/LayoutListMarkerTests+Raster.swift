import AppKit
import CoreText
import Testing

@testable import FundamentalLayout

extension LayoutListMarkerTests
{
    @MainActor
    @Test("generated marker glyphs reproduce native Core Text pixels")
    func nativePixels() throws
    {
        let font = try LayoutMarkerRasterFixture.font()
        let native = NativeTextKit2Layout()
        let numbers: [Int?] = [nil, 1, 10, 100, 999, 10_000, Int.max]
        for number in numbers
        {
            let source = try LayoutMarkerRasterFixture.source(number: number)
            let line = CTLineCreateWithAttributedString(NSAttributedString(
                string: source.label, attributes: [.font: font]
            ))
            for scale in [1.0, 2]
            {
                for offset in [0.0, 0.25]
                {
                    let x = 16 + offset
                    let y = 32 + 2 * offset
                    let marker = try native.listMarker(
                        source, baselineX: x, baselineY: y
                    )
                    #expect(marker.advance == CTLineGetTypographicBounds(
                        line, nil, nil, nil
                    ))
                    #expect(marker.glyphRuns.allSatisfy
                    {
                        $0.font.postScriptName == font.fontName
                    })
                    let expected = try LayoutMarkerRasterFixture.image(
                        scale: scale
                    )
                    {
                        $0.textPosition = CGPoint(x: x, y: y)
                        CTLineDraw(line, $0)
                    }
                    let actual = try LayoutMarkerRasterFixture.image(
                        scale: scale
                    )
                    {
                        LayoutMarkerRasterFixture.draw(marker, font: font,
                                                       in: $0)
                    }
                    let expectedData = try #require(expected.dataProvider?.data)
                    let actualData = try #require(actual.dataProvider?.data)
                    let equal = (actualData as Data) == (expectedData as Data)
                    #expect(equal, "Marker \(source.label), scale \(scale)")
                    if number == 100 && scale == 2 && offset == 0.25
                    {
                        try LayoutMarkerRasterFixture.capture(
                            expected, name: "native-100"
                        )
                        try LayoutMarkerRasterFixture.capture(
                            actual, name: "owned-100"
                        )
                    }
                }
            }
        }
    }
}
