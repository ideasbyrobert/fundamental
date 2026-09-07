import Testing

@testable import FundamentalRaster
@testable import FundamentalViewport

@Suite("Unsupported reader list roles do not become body interaction regions")
struct RasterListRefusalTests
{
    @Test("both unadmitted list roles refuse while admitted body remains exact")
    func listRolesRefuse()
    {
        #expect(ViewportRasterizer.role(.prose(.bulleted)) == nil)
        #expect(ViewportRasterizer.role(.prose(.numbered)) == nil)
        #expect(ViewportRasterizer.role(.prose(.body)) == .body)
    }
}
