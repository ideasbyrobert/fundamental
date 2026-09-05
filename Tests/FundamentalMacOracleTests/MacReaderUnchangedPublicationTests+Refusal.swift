import Testing

@testable import FundamentalMacOracle

extension MacReaderUnchangedPublicationTests
{
    @Test("invalid surfaces preserve an admitted selection and execution")
    func invalidSurface() throws
    {
        let model = try MacOracleTestSurface.model()
        let (first, last) = try MacReaderRasterPublicationTests.positions(
            in: model
        )
        #expect(model.showSelection(anchor: first, focus: last))
        let snapshot = model.snapshot
        let execution = model.rasterExecution
        let layouts = model.layoutExecutionCount
        for (width, height) in [(64.0, 680.0), (820.0, 0.0)]
        {
            #expect(try !Self.update(model, width: width, height: height))
            #expect(model.snapshot == snapshot)
            #expect(model.layoutExecutionCount == layouts)
            MacReaderRasterPublicationTests.expectSameExecution(
                execution,
                model.rasterExecution
            )
        }
        #expect(try Self.update(model))
        #expect(model.snapshot == snapshot)
    }
}
