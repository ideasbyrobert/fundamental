import Testing

@testable import FundamentalRaster
@testable import FundamentalViewport
@testable import FundamentalProjection

@Suite("Unsupported reader list roles do not become body interaction regions")
struct RasterListRefusalTests
{
    @Test("both unadmitted list roles refuse while admitted body remains exact")
    func listRolesRefuse() throws
    {
        let position = try #require(ProjectedListPosition(index: 0, count: 1))
        #expect(ViewportRasterizer.role(.prose(.bulleted(position))) == nil)
        #expect(ViewportRasterizer.role(.prose(.numbered(position))) == nil)
        #expect(ViewportRasterizer.role(.prose(.body)) == .body)
    }
}
