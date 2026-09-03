import FundamentalPresentation
import Testing

extension MacRasterExecutorTests
{
    func draw(
        _ snapshot: PresentationSnapshot
    ) throws -> MacBitmapSurface
    {
        let surface = try #require(MacBitmapSurface(snapshot))
        #expect(surface.draw(snapshot))
        return surface
    }
}
