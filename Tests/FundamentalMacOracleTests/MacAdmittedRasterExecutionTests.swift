import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

@Suite("Admitted native raster execution")
@MainActor
struct MacAdmittedRasterExecutionTests
{
    @Test("closed forms retain generation and stable execution")
    func closedFormsRetainTruth() throws
    {
        let model = try MacOracleTestSurface.model()
        guard case let .document(lineage, document)
                = model.rasterExecution
        else
        {
            throw MacOracleTestFailure.admission
        }
        #expect(lineage == model.snapshot.lineage)
        let (resident, line) = try MacReaderInteractionTests.line(
            in: model.snapshot
        )
        let firstSite = try #require(line.caretSites.first)
        let lastSite = try #require(line.caretSites.last)
        let first = PresentationTextPosition(
            residentID: resident.residentID,
            sourcePoint: firstSite.sourcePoint
        )
        let last = PresentationTextPosition(
            residentID: resident.residentID,
            sourcePoint: lastSite.sourcePoint
        )
        #expect(model.showCaret(at: first))
        guard case let .caret(caretLineage, caretDocument, caret)
                = model.rasterExecution,
              case let .caret(_, sourceCaret) = model.snapshot
        else
        {
            throw MacOracleTestFailure.admission
        }
        #expect(caretLineage == model.snapshot.lineage)
        #expect(caretDocument === document)
        #expect(caret.source == sourceCaret)
        #expect(model.showSelection(anchor: first, focus: last))
        guard case let .selection(
            selectionLineage,
            selectionDocument,
            selection
        ) = model.rasterExecution,
              case let .selection(_, sourceSelection) = model.snapshot
        else
        {
            throw MacOracleTestFailure.admission
        }
        #expect(selectionLineage == model.snapshot.lineage)
        #expect(selectionDocument === document)
        #expect(selection.source == sourceSelection)
        #expect(selection.fragments.count == sourceSelection.fragments.count)
    }

}
