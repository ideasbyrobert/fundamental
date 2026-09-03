import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacNativeResourceAdmissionTests
{
    @Test("poisoned color refuses the complete execution")
    func poisonedColorRefusesExecution() throws
    {
        let source = try MacOracleTestSurface.snapshot()
        let colorSpace = source.presentedDocument.plane.colorSpace
        let falseIdentity = try #require(PresentationColorSpaceIdentity(
            name: colorSpace.name + " false",
            profile: colorSpace.profile,
            componentCount: colorSpace.componentCount
        ))
        let batch = try #require(
            MacRasterSnapshotFixture.firstTextBatch(in: source)
        )
        let color = try #require(PresentationColor(
            colorSpace: falseIdentity,
            components: batch.color.components,
            alpha: batch.color.alpha
        ))
        let snapshot = try #require(
            MacRasterSnapshotFixture.replacingFirstGlyphBatch(
                in: source,
                transform:
                {
                    MacRasterSnapshotFixture.glyphBatch(
                        $0,
                        color: color
                    )
                }
            )
        )
        #expect(MacRasterExecutor().admit(snapshot) == nil)
    }

    @Test("oversized glyph identifier refuses complete execution")
    func oversizedGlyphRefusesExecution() throws
    {
        let source = try MacOracleTestSurface.snapshot()
        let snapshot = try #require(
            MacRasterSnapshotFixture.replacingFirstGlyphBatch(
                in: source,
                transform:
                {
                    batch in
                    let glyph = PresentationGlyph(
                        identifier: UInt32(UInt16.max) + 1,
                        position: batch.firstGlyph.position,
                        advance: batch.firstGlyph.advance,
                        sourceSlices: batch.firstGlyph.sourceSlices
                    )
                    return MacRasterSnapshotFixture.glyphBatch(
                        batch,
                        firstGlyph: glyph
                    )
                }
            )
        )
        #expect(MacRasterExecutor().admit(snapshot) == nil)
    }
}
