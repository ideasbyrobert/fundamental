import Foundation
import Testing

@testable import FundamentalMacOracle

@Suite("An admitted color space retains established identity")
@MainActor
struct MacAdmittedColorSpaceTests
{
    @Test("retained identity agrees with independent native inspection")
    func exactNativeIdentity() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let identity = snapshot.presentedDocument.plane.colorSpace
        let space = try #require(MacAdmittedColorSpace(identity))
        let graphicsData = try #require(
            space.graphics.copyICCData() as Data?
        )
        let nativeGraphics = try #require(space.native.cgColorSpace)
        let nativeData = try #require(nativeGraphics.copyICCData() as Data?)
        #expect(space.identity == identity)
        #expect(Array(graphicsData) == identity.profile)
        #expect(Array(nativeData) == identity.profile)
        #expect(space.graphics.numberOfComponents == identity.componentCount)
        #expect(space.native.numberOfColorComponents == identity.componentCount)
        #expect(space.native.localizedName == identity.name)
    }
}
