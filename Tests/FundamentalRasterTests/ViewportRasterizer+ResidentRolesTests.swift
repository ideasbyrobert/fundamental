import Testing

@testable import FundamentalRaster
@testable import FundamentalViewport
@testable import FundamentalProjection

@Suite("Reader list roles retain their item position")
struct RasterListRoleTests
{
    @Test("both list kinds map exactly while body remains body")
    func listRoles() throws
    {
        let position = try #require(ProjectedListPosition(index: 9, count: 10))
        let raster = try #require(RasterListPosition(index: 9, count: 10))
        #expect(
            ViewportRasterizer.role(.prose(.bulleted(position)))
                == .bulleted(raster)
        )
        #expect(
            ViewportRasterizer.role(.prose(.numbered(position)))
                == .numbered(raster)
        )
        #expect(ViewportRasterizer.role(.prose(.body)) == .body)
    }
}
