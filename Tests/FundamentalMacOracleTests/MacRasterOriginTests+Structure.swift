import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacRasterOriginTests
{
    @Test("structural residents cannot supply a glyph drawing origin")
    func structuralOriginsRefuse() throws
    {
        let fixture = try MacRasterOriginFixture.specimen()
        for content in MacRasterOriginFixture.structuralContents
        {
            let resident = MacRasterOriginFixture.resident(
                fixture.resident, content: content
            )
            let snapshot = try MacRasterOriginFixture.snapshot(
                fixture.snapshot, residents: [resident],
                marks: [.glyphs(fixture.batch)]
            )
            #expect(MacRasterExecutor().admit(snapshot) == nil)
        }
    }

    @Test("glyph-free structures and empty source need no drawing origin")
    func glyphFreeDocumentsRemainValid() throws
    {
        let fixture = try MacRasterOriginFixture.specimen()
        let empty = MacRasterOriginFixture.line(
            fixture.line, baseline: fixture.line.baseline, empty: true
        )
        let contents = MacRasterOriginFixture.structuralContents
            + [.body(empty)]
        for content in contents
        {
            let resident = MacRasterOriginFixture.resident(
                fixture.resident, content: content
            )
            let snapshot = try MacRasterOriginFixture.snapshot(
                fixture.snapshot, residents: [resident], marks: []
            )
            let execution = try #require(MacRasterExecutor().admit(snapshot))
            #expect(execution.documentExecution.marks.isEmpty)
            #expect(execution.documentExecution.source
                == snapshot.presentedDocument)
        }
    }
}
