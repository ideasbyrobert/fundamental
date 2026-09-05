import Testing

@testable import FundamentalMacOracle

extension MacAdmittedColorSpaceTests
{
    @Test("altered names invalid profiles and component counts still refuse")
    func invalidNativeIdentities() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let identity = snapshot.presentedDocument.plane.colorSpace
        for mismatch in try MacColorSpaceIdentityFixture.mismatches(identity)
        {
            #expect(MacAdmittedColorSpace(mismatch) == nil)
        }
        #expect(MacAdmittedColorSpace(identity) != nil)
    }
}
