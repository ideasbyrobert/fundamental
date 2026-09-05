import Testing

@testable import FundamentalMacOracle

extension MacSynchronizationObservationTests
{
    @Test("repeated admitted drawing preserves exact bitmap pixels")
    func repeatedDrawing() throws
    {
        let model = try MacOracleTestSurface.model()
        let execution = model.rasterExecution
        let first = try #require(MacBitmapSurface(model.snapshot))
        let repeated = try #require(MacBitmapSurface(model.snapshot))
        first.draw(execution)
        for _ in 0 ..< 3
        {
            repeated.draw(execution)
        }
        #expect(first.containsInk(in: first.pixelBounds))
        #expect(first.changedPixels(
            from: repeated,
            in: first.pixelBounds
        ).isEmpty)
        MacReaderRasterPublicationTests.expectSameExecution(
            execution,
            model.rasterExecution
        )
    }
}
