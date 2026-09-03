import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacNativeResourceAdmissionTests
{
    @Test("poisoned ICC identity refuses the complete execution")
    func poisonedICCRefusesExecution() throws
    {
        let source = try MacOracleTestSurface.snapshot()
        let identity = source.presentedDocument.plane.colorSpace
        let poisoned = try #require(PresentationColorSpaceIdentity(
            name: identity.name + " poisoned",
            profile: identity.profile,
            componentCount: identity.componentCount
        ))
        let snapshot = MacRasterSnapshotFixture.replacingColorSpace(
            in: source,
            with: poisoned
        )
        #expect(MacRasterExecutor().admit(snapshot) == nil)
    }

    @Test("poisoned font refuses the complete execution")
    func poisonedFontRefusesExecution() throws
    {
        let source = try MacOracleTestSurface.snapshot()
        let snapshot = try #require(
            MacRasterSnapshotFixture.replacingFirstGlyphBatch(
                in: source,
                transform:
                {
                    batch in
                    let font = PresentationFontIdentity(
                        postScriptName: batch.font.postScriptName,
                        uniqueName: batch.font.uniqueName,
                        versionName: batch.font.versionName + " poisoned",
                        pointSize: batch.font.pointSize,
                        matrix: batch.font.matrix,
                        variations: batch.font.variations,
                        metrics: batch.font.metrics
                    )
                    return MacRasterSnapshotFixture.glyphBatch(
                        batch,
                        font: font
                    )
                }
            )
        )
        #expect(MacRasterExecutor().admit(snapshot) == nil)
    }
}
