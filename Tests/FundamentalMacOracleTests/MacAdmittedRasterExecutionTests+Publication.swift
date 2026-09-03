import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacAdmittedRasterExecutionTests
{
    @Test("publication refuses mismatched generation form and storage")
    func publicationRefusesMismatches() throws
    {
        let source = try MacOracleTestSurface.snapshot()
        let executor = MacRasterExecutor()
        let execution = try #require(executor.admit(source))
        let document = execution.documentExecution
        let wrongGeneration = MacAdmittedRasterExecution.document(
            lineage: PresentationLineage(
                raster: source.lineage.raster,
                generation: source.lineage.generation + 1,
                specification: source.lineage.specification
            ),
            document: document
        )
        #expect(MacReaderPublication(
            snapshot: source,
            execution: wrongGeneration
        ) == nil)
        let unrelated = try MacOracleTestSurface.snapshot(width: 1_200)
        let unrelatedExecution = try #require(executor.admit(unrelated))
        #expect(MacReaderPublication(
            snapshot: source,
            execution: unrelatedExecution
        ) == nil)
        let model = try MacOracleTestSurface.model()
        let documentSnapshot = model.snapshot
        let (resident, line) = try MacReaderInteractionTests.line(
            in: documentSnapshot
        )
        let site = try #require(line.caretSites.first)
        let position = PresentationTextPosition(
            residentID: resident.residentID,
            sourcePoint: site.sourcePoint
        )
        #expect(model.showCaret(at: position))
        #expect(MacReaderPublication(
            snapshot: documentSnapshot,
            execution: model.rasterExecution
        ) == nil)
    }
}
