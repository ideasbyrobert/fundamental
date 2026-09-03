import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacAdmittedRasterExecutionTests
{
    @Test("equal document values with new storage replace execution")
    func equalValuesDoNotAuthorizeReuse() throws
    {
        let source = try MacOracleTestSurface.snapshot()
        let copied = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: source.presentedDocument.marks
        )
        #expect(source.presentedDocument == copied.presentedDocument)
        #expect(!source.presentedDocument.sharesStorage(
            with: copied.presentedDocument
        ))
        let executor = MacRasterExecutor()
        let first = try #require(executor.admit(source))
        let second = try #require(executor.admit(
            copied,
            reusing: first.documentExecution
        ))
        #expect(second.documentExecution !== first.documentExecution)
    }

    @Test("same generation with changed lineage refuses pairing")
    func changedLineageRefusesPairing() throws
    {
        let source = try MacOracleTestSurface.snapshot()
        let other = try MacOracleTestSurface.snapshot(height: 600)
        let lineage = PresentationLineage(
            raster: other.lineage.raster,
            generation: source.lineage.generation,
            specification: source.lineage.specification
        )
        #expect(lineage != source.lineage)
        let document = PresentedDocument(
            lineage: lineage,
            storage: source.presentedDocument.storage
        )
        let altered = PresentationSnapshot.document(document)
        let execution = try #require(
            MacRasterExecutor().admit(source)
        )
        #expect(document.sharesStorage(
            with: execution.documentExecution.source
        ))
        #expect(altered.lineage.generation == execution.generation)
        #expect(MacReaderPublication(
            snapshot: altered,
            execution: execution
        ) == nil)
    }
}
