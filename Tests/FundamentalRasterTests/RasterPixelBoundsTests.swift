import Testing

@testable import FundamentalRaster

@Suite("Raster pixel bounds")
struct RasterPixelBoundsTests
{
    @Test("integral and fractional scales round outward exactly")
    func scales() throws
    {
        let bounds = try RasterFixture.rectangle(
            x: -0.25,
            y: 0.25,
            width: 10,
            height: 4
        )
        let one = try #require(RasterPixelBounds(
            logicalBounds: bounds,
            backingScale: 1
        ))
        let two = try #require(RasterPixelBounds(
            logicalBounds: bounds,
            backingScale: 2
        ))
        let fractional = try #require(RasterPixelBounds(
            logicalBounds: bounds,
            backingScale: 1.5
        ))
        #expect((one.minimumX, one.maximumX) == (-1, 10))
        #expect((two.minimumX, two.maximumX) == (-1, 20))
        #expect((fractional.minimumY, fractional.maximumY) == (0, 7))
        #expect(one.area == one.width * one.height)
    }

    @Test("nonpositive nonfinite empty and overflowing pixels refuse")
    func refusal() throws
    {
        let bounds = try RasterFixture.rectangle(
            x: 0,
            y: 0,
            width: 1,
            height: 1
        )
        let tiny = try RasterFixture.rectangle(
            x: 0,
            y: 0,
            width: .leastNonzeroMagnitude,
            height: .leastNonzeroMagnitude
        )
        #expect(RasterPixelBounds(
            logicalBounds: bounds,
            backingScale: 0
        ) == nil)
        #expect(RasterPixelBounds(
            logicalBounds: bounds,
            backingScale: .infinity
        ) == nil)
        #expect(RasterPixelBounds(
            logicalBounds: tiny,
            backingScale: .leastNonzeroMagnitude
        ) == nil)
        #expect(RasterPixelBounds(
            logicalBounds: bounds,
            backingScale: Double.greatestFiniteMagnitude
        ) == nil)
    }
}
