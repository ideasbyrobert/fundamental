import Testing

extension LayoutGlyphBaselineTests
{
    @Test("owned baseline glyphs reproduce independent native pixels")
    func nativePixels() throws
    {
        for fixture in try LayoutBaselineFixture.cases()
        {
            guard !fixture.name.contains("decorated")
            else
            {
                continue
            }
            for scale in [1.0, 2]
            {
                let native = try LayoutBaselineRaster(
                    fixture, scale: scale, native: true
                )
                let owned = try LayoutBaselineRaster(
                    fixture, scale: scale, native: false
                )
                let matches = owned.data == native.data
                #expect(matches, "\(fixture.name) at \(scale)x")
                let name = "baseline-\(fixture.name)-\(Int(scale))"
                try LayoutMarkerRasterFixture.capture(
                    native.image, name: name + "-native"
                )
                try LayoutMarkerRasterFixture.capture(
                    owned.image, name: name + "-owned"
                )
            }
        }
    }
}
