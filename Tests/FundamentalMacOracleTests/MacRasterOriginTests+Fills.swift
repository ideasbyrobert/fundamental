import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacRasterOriginTests
{
    @Test("fill-only drawing does not require unique text residents")
    func fillOnlyDocumentsRemainValid() throws
    {
        let fixture = try MacRasterOriginFixture.specimen()
        let fills = try MacRasterFillFixture.overlapping(in: fixture.snapshot)
        let resident = MacRasterOriginFixture.resident(
            fixture.resident, content: .table
        )
        let marks: [PresentationMark] = [
            .fill(fills.second), .fill(fills.first)
        ]
        let snapshot = try MacRasterOriginFixture.snapshot(
            fixture.snapshot, residents: [resident, resident], marks: marks
        )
        let execution = try #require(MacRasterExecutor().admit(snapshot))
        #expect(execution.documentExecution.marks.count == 2)
        #expect(execution.documentExecution.source.marks == marks)
    }
}
