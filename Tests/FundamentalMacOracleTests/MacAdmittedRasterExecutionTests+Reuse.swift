import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

extension MacAdmittedRasterExecutionTests
{
    @Test("shared storage reuses one document execution")
    func sharedStorageReusesDocumentExecution() throws
    {
        let source = try MacOracleTestSurface.snapshot()
        let executor = MacRasterExecutor()
        let first = try #require(executor.admit(source))
        let replay = MacRasterSnapshotFixture.documentOnly(source)
        let second = try #require(executor.admit(
            replay,
            reusing: first.documentExecution
        ))
        #expect(second.documentExecution === first.documentExecution)
    }

    @Test("changed marks scale and residence replace execution")
    func changedSurfacesReplaceDocumentExecution() throws
    {
        let executor = MacRasterExecutor()
        let source = try MacOracleTestSurface.snapshot()
        let admitted = try #require(executor.admit(source))
        let changedMarks = MacRasterSnapshotFixture.replacingMarks(
            in: source,
            with: Array(source.presentedDocument.marks.dropLast())
        )
        let marksExecution = try #require(executor.admit(
            changedMarks,
            reusing: admitted.documentExecution
        ))
        #expect(marksExecution.documentExecution
            !== admitted.documentExecution)
        let scaled = try MacOracleTestSurface.snapshot(backingScale: 2)
        let scaleExecution = try #require(executor.admit(
            scaled,
            reusing: admitted.documentExecution
        ))
        #expect(scaleExecution.documentExecution
            !== admitted.documentExecution)
        let model = try MacOracleTestSurface.model()
        let near = model.rasterExecution.documentExecution
        #expect(model.update(
            viewportWidth: 820,
            viewportHeight: 680,
            visibleOriginY: model.documentHeight,
            screen: try MacOracleTestSurface.screen(),
            appearance: try MacOracleTestSurface.appearance()
        ))
        #expect(model.rasterExecution.documentExecution !== near)
    }

    @Test("appearance replacement and refused input preserve truth")
    func appearanceAndRefusalPreserveTruth() throws
    {
        let model = try MacOracleTestSurface.model()
        let before = model.rasterExecution.documentExecution
        #expect(model.update(
            viewportWidth: 820,
            viewportHeight: 680,
            visibleOriginY: 0,
            screen: try MacOracleTestSurface.screen(),
            appearance: try MacOracleTestSurface.appearance(.darkAqua)
        ))
        let dark = model.rasterExecution.documentExecution
        #expect(dark !== before)
        let publication = model.rasterExecution
        #expect(!model.update(
            viewportWidth: 64,
            viewportHeight: 680,
            visibleOriginY: 0,
            screen: try MacOracleTestSurface.screen(),
            appearance: try MacOracleTestSurface.appearance(.darkAqua)
        ))
        #expect(model.rasterExecution.documentExecution === dark)
        #expect(model.rasterExecution.generation
            == publication.generation)
    }
}
