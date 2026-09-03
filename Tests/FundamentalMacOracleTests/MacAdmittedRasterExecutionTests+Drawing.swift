import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

extension MacAdmittedRasterExecutionTests
{
    @Test("one admitted execution draws repeatable exact pixels")
    func admittedExecutionDrawsRepeatably() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let execution = try #require(
            MacRasterExecutor().admit(snapshot)
        )
        let first = try #require(MacBitmapSurface(snapshot))
        let second = try #require(MacBitmapSurface(snapshot))
        first.draw(execution)
        second.draw(execution)
        #expect(first.changedPixels(
            from: second,
            in: snapshot.presentedDocument.plane.pixelBounds
        ).isEmpty)
    }

    @Test("initial summit preparation asks for one admission")
    func initialPreparationAdmitsOnce() throws
    {
        let (_, surface) = try MacOracleTestPreparation.make()
        let executor = MacRasterExecutor()
        var executions: [MacAdmittedRasterExecution] = []
        let preparation = SummitPresentationPreparation(
            surface: surface,
            admitting:
            {
                guard let execution = executor.admit($0)
                else
                {
                    return false
                }
                executions.append(execution)
                return true
            }
        )
        #expect(preparation != nil)
        #expect(executions.count == 1)
    }
}
