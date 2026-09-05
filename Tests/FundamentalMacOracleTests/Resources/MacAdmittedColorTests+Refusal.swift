import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

extension MacAdmittedColorTests
{
    @Test("each color requires the complete retained identity")
    func mismatchedIdentities() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let identity = snapshot.presentedDocument.plane.colorSpace
        let space = try #require(MacAdmittedColorSpace(identity))
        for mismatch in try MacColorSpaceIdentityFixture.mismatches(identity)
        {
            let color = try #require(PresentationColor(
                colorSpace: mismatch,
                components: Array(
                    repeating: 0.5,
                    count: mismatch.componentCount
                ),
                alpha: 1
            ))
            #expect(MacAdmittedColor(color, colorSpace: space) == nil)
        }
        #expect(space.identity == identity)
    }

    @Test("independently constructed equal identities admit without pointers")
    func reconstructedEqualIdentity() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let identity = snapshot.presentedDocument.plane.colorSpace
        let space = try #require(MacAdmittedColorSpace(identity))
        let equal = try #require(PresentationColorSpaceIdentity(
            name: String(identity.name.map { $0 }),
            profile: identity.profile.map { $0 },
            componentCount: identity.componentCount
        ))
        let color = try #require(PresentationColor(
            colorSpace: equal,
            components: Array(repeating: 0.25, count: equal.componentCount),
            alpha: 0.375
        ))
        let admitted = try #require(MacAdmittedColor(color, colorSpace: space))
        #expect(equal == identity)
        #expect(admitted.graphics.components?.map(Double.init)
            == color.components + [color.alpha])
    }
}
