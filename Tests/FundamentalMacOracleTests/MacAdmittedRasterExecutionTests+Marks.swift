import CoreGraphics
import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacAdmittedRasterExecutionTests
{
    @Test("document execution retains every ordered native mark")
    func documentExecutionRetainsExactMarks() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let execution = try #require(
            MacRasterExecutor().admit(snapshot)
        )
        let admitted = execution.documentExecution
        let source = snapshot.presentedDocument
        #expect(admitted.source == source)
        #expect(admitted.marks.count == source.marks.count)
        for (sourceMark, admittedMark) in zip(
            source.marks,
            admitted.marks
        )
        {
            switch (sourceMark, admittedMark)
            {
            case let (.fill(sourceFill), .fill(fill)):
                #expect(fill.residentID == sourceFill.residentID)
                #expect(fill.logicalBounds == Self.rectangle(
                    sourceFill.logicalBounds
                ))
            case let (.glyphs(sourceBatch), .glyphs(batch)):
                #expect(batch.residentID == sourceBatch.residentID)
                #expect(batch.glyphs == sourceBatch.glyphs.map
                {
                    CGGlyph($0.identifier)
                })
                #expect(batch.positions == sourceBatch.glyphs.map
                {
                    CGPoint(x: $0.position.x, y: -$0.position.y)
                })
                #expect(batch.clipBounds == Self.rectangle(
                    sourceBatch.clipBounds
                ))
            default:
                Issue.record("Native mark order changed")
            }
        }
    }

    private static func rectangle(
        _ value: PresentationRectangle
    ) -> CGRect
    {
        CGRect(
            x: value.origin.x,
            y: value.origin.y,
            width: value.size.width,
            height: value.size.height
        )
    }
}
