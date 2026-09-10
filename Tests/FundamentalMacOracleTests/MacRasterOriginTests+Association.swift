import CoreGraphics
import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacRasterOriginTests
{
    @Test("every text resident supplies its retained fractional baseline")
    func textResidentOrigins() throws
    {
        let fixture = try MacRasterOriginFixture.specimen()
        let origin = try #require(PresentationPoint(x: 19.25, y: 27.5))
        let line = MacRasterOriginFixture.line(fixture.line, baseline: origin)
        var contents: [PresentedResidentContent] = [
            .body(line), .title(line), .code(line), .caption(line),
            .headerCell(row: 0, cell: 0, content: .line(line)),
            .bodyCell(row: 1, cell: 0, content: .line(line))
        ]
        let levels: [PresentationHeadingLevel] = [
            .one, .two, .three, .four, .five, .six
        ]
        contents += levels.map { .section($0, line) }
        for content in contents
        {
            let resident = MacRasterOriginFixture.resident(
                fixture.resident, content: content
            )
            let snapshot = try MacRasterOriginFixture.snapshot(
                fixture.snapshot, residents: [resident],
                marks: [.glyphs(fixture.batch)]
            )
            let execution = try #require(MacRasterExecutor().admit(snapshot))
            let mark = try #require(execution.documentExecution.marks.first)
            guard case let .glyphs(batch) = mark
            else
            {
                throw MacOracleTestFailure.admission
            }
            #expect(batch.origin == CGPoint(x: 19.25, y: 27.5))
            #expect(execution.documentExecution.source
                == snapshot.presentedDocument)
            #expect(batch.positions.map
            {
                CGPoint(x: $0.x + batch.origin.x,
                        y: batch.origin.y - $0.y)
            } == fixture.batch.glyphs.map
            {
                CGPoint(x: $0.position.x, y: $0.position.y)
            })
        }
    }

    @Test("missing and repeated resident identities refuse glyph admission")
    func ambiguousOriginsRefuse() throws
    {
        let fixture = try MacRasterOriginFixture.specimen()
        let others = fixture.snapshot.presentedDocument.residents.all.filter
        {
            $0.residentID != fixture.batch.residentID
        }
        let structural = MacRasterOriginFixture.resident(
            fixture.resident, content: .table
        )
        for residents in [
            others, [fixture.resident, fixture.resident],
            [fixture.resident, fixture.resident, fixture.resident],
            [structural, fixture.resident], [fixture.resident, structural]
        ]
        {
            let snapshot = try MacRasterOriginFixture.snapshot(
                fixture.snapshot, residents: residents,
                marks: [.glyphs(fixture.batch)]
            )
            #expect(MacRasterExecutor().admit(snapshot) == nil)
        }
    }
}
