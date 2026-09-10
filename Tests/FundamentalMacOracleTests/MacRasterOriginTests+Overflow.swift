import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacRasterOriginTests
{
    @Test("finite source coordinates cannot overflow native subtraction")
    func unrepresentableRelativePositionsRefuse() throws
    {
        let fixture = try MacRasterOriginFixture.specimen()
        let limit = Double.greatestFiniteMagnitude
        for (x, y) in [(limit, 0.0), (-limit, 0), (0, limit), (0, -limit)]
        {
            let point = try #require(PresentationPoint(x: x, y: y))
            let origin = try #require(PresentationPoint(x: -x, y: -y))
            let glyph = fixture.batch.firstGlyph
            let batch = MacRasterSnapshotFixture.glyphBatch(
                fixture.batch, firstGlyph: PresentationGlyph(
                    identifier: glyph.identifier, position: point,
                    advance: glyph.advance, sourceSlices: glyph.sourceSlices
                )
            )
            let line = MacRasterOriginFixture.line(
                fixture.line, baseline: origin
            )
            let resident = MacRasterOriginFixture.resident(
                fixture.resident, content: .body(line)
            )
            let snapshot = try MacRasterOriginFixture.snapshot(
                fixture.snapshot, residents: [resident],
                marks: [.glyphs(batch)]
            )
            #expect(MacRasterExecutor().admit(snapshot) == nil)
        }
    }
}
