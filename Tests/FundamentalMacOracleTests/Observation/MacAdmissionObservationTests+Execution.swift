import Testing

@testable import FundamentalMacOracle

extension MacAdmissionObservationTests
{
    @Test("complete execution admission does not receive reusable storage")
    func execution() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        MacAdmissionWorkload(snapshot).report("execution")
        let executor = MacRasterExecutor()
        let reference = try #require(executor.admit(snapshot))
        let expected = try #require(MacBitmapSurface(snapshot))
        expected.draw(reference)
        #expect(expected.containsInk(in: expected.pixelBounds))
        _ = try MacAdmissionMeasurement.measure(
            "execution",
            prepare: { _ in snapshot },
            action: { executor.admit($0) },
            consume:
            {
                snapshot, value in
                let admitted = try #require(value)
                #expect(admitted.lineage == snapshot.lineage)
                #expect(admitted.documentExecution !== reference
                    .documentExecution)
                #expect(admitted.documentExecution.source
                    == snapshot.presentedDocument)
                #expect(admitted.documentExecution.marks.count
                    == snapshot.presentedDocument.marks.count)
                let actual = try #require(MacBitmapSurface(snapshot))
                actual.draw(admitted)
                #expect(actual.changedPixels(
                    from: expected,
                    in: actual.pixelBounds
                ).isEmpty)
            }
        )
    }
}
