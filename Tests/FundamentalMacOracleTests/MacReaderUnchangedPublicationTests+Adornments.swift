import Testing

@testable import FundamentalMacOracle

extension MacReaderUnchangedPublicationTests
{
    @Test(
        "equal updates retain exact caret and selection publications",
        arguments: [false, true]
    )
    func adornments(selection: Bool) throws
    {
        let model = try MacOracleTestSurface.model()
        let (first, last) = try MacReaderRasterPublicationTests.positions(
            in: model
        )
        if selection
        {
            #expect(model.showSelection(anchor: first, focus: last))
        }
        else
        {
            #expect(model.showCaret(at: first))
        }
        let snapshot = model.snapshot
        let execution = model.rasterExecution
        #expect(try Self.update(model))
        #expect(model.snapshot == snapshot)
        #expect(model.snapshot.presentedDocument.sharesStorage(
            with: snapshot.presentedDocument
        ))
        MacReaderRasterPublicationTests.expectSameExecution(
            execution,
            model.rasterExecution
        )
    }
}
