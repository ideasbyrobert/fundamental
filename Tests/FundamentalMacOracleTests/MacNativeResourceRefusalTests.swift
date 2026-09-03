import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacNativeResourceAdmissionTests
{
    @Test("source-bound recovery refuses an unrelated source")
    func sourceBoundRecoveryRefusesPoisonedSource() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let batch = try #require(snapshot.presentedDocument.marks.compactMap
        {
            mark -> PresentationGlyphBatch? in
            guard case let .glyphs(batch) = mark,
                  batch.font.uniqueName.contains(".SF Devanagari")
            else
            {
                return nil
            }
            return batch
        }.first)
        #expect(MacAdmittedFont(
            batch.font,
            sourceText: "Unrelated Latin source"
        ) == nil)
    }

    @Test("a poisoned font identity refuses atomically")
    func poisonedFontIdentityRefuses() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let batch = try #require(snapshot.presentedDocument.marks.compactMap
        {
            mark -> PresentationGlyphBatch? in
            guard case let .glyphs(batch) = mark,
                  batch.sourceSlices.map(\.text).joined() == "שלום"
            else
            {
                return nil
            }
            return batch
        }.first)
        let poisoned = PresentationFontIdentity(
            postScriptName: batch.font.postScriptName,
            uniqueName: batch.font.uniqueName,
            versionName: batch.font.versionName + " poisoned",
            pointSize: batch.font.pointSize,
            matrix: batch.font.matrix,
            variations: batch.font.variations,
            metrics: batch.font.metrics
        )
        let source = batch.sourceSlices.map(\.text).joined()
        #expect(MacAdmittedFont(
            poisoned,
            sourceText: source
        ) == nil)
    }

    @Test("an altered ICC identity refuses substitution")
    func alteredColorSpaceIdentityRefuses() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let identity = snapshot.presentedDocument.plane.colorSpace
        let altered = try #require(PresentationColorSpaceIdentity(
            name: identity.name + " altered",
            profile: identity.profile,
            componentCount: identity.componentCount
        ))
        #expect(MacAdmittedColorSpace(altered) == nil)
    }
}
