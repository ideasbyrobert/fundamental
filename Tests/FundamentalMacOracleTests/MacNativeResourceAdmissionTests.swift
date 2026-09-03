import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

@Suite("The macOS summit native resources")
@MainActor
struct MacNativeResourceAdmissionTests
{
    @Test("every shaped glyph batch reconstructs its exact font")
    func exactFontsReconstruct() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        for mark in snapshot.presentedDocument.marks
        {
            guard case let .glyphs(batch) = mark
            else
            {
                continue
            }
            let source = batch.sourceSlices.map(\.text).joined()
            let admitted = MacAdmittedFont(
                batch.font,
                sourceText: source
            )
            #expect(admitted != nil, "\(batch.font.uniqueName): \(source)")
        }
    }

    @Test("every presentation resource is admitted together")
    func presentationResourcesAreAdmitted() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        #expect(MacRasterExecutor().admits(snapshot))
    }
}
