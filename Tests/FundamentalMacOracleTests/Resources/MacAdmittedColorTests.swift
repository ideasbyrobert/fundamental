import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

@Suite("Admitted native colors retain exact components")
@MainActor
struct MacAdmittedColorTests
{
    @Test("repeated colors retain every component and alpha")
    func repeatedComponents() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let identity = snapshot.presentedDocument.plane.colorSpace
        let space = try #require(MacAdmittedColorSpace(identity))
        for value in [0.0, 0.25, 1.0, 0.25]
        {
            for alpha in [0.0, 0.375, 1.0]
            {
                let components = Array(
                    repeating: value,
                    count: identity.componentCount
                )
                let color = try #require(PresentationColor(
                    colorSpace: identity,
                    components: components,
                    alpha: alpha
                ))
                let admitted = try #require(MacAdmittedColor(
                    color,
                    colorSpace: space
                ))
                #expect(admitted.graphics.components?.map(Double.init)
                    == components + [alpha])
            }
        }
    }
}
