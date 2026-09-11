import Foundation
import Testing

@testable import FundamentalLayout

extension LayoutListMarkerTests
{
    @MainActor
    @Test("marker baselines translate every retained glyph and ink bound")
    func translation() throws
    {
        let native = NativeTextKit2Layout()
        let source = try LayoutMarkerRasterFixture.source(number: 100)
        let origin = try native.listMarker(
            source, baselineX: 0, baselineY: 0
        )
        let shifted = try native.listMarker(
            source, baselineX: 19.25, baselineY: 37.5
        )
        let runs = try origin.glyphRuns.map
        {
            try native.translated($0, dx: 19.25, dy: 37.5)
        }
        let bounds = try native.translated(
            origin.inkBounds, dx: 19.25, dy: 37.5
        )
        #expect(shifted.glyphRuns == runs)
        #expect(shifted.inkBounds == bounds)
        #expect(shifted.advance == origin.advance)
        #expect(shifted.source == origin.source)
        for invalid in [Double.infinity, -.infinity, .nan]
        {
            #expect(throws: LayoutFailure.nonfiniteNativeGeometry)
            {
                try native.listMarker(source, baselineX: invalid, baselineY: 0)
            }
            #expect(throws: LayoutFailure.nonfiniteNativeGeometry)
            {
                try native.listMarker(source, baselineX: 0, baselineY: invalid)
            }
        }
    }
}
