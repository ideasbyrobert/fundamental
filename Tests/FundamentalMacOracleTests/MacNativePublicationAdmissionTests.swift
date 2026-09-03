import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

extension MacNativeResourceAdmissionTests
{
    @Test("native refusal prevents initial presentation publication")
    func nativeRefusalPreventsInitialPublication() throws
    {
        let (_, surface) = try MacOracleTestPreparation.make()
        #expect(SummitPresentationPreparation(
            surface: surface,
            admitting: { _ in false }
        ) == nil)
    }

    @Test("the recorded PostScript name reconstructs the Hebrew font")
    func postScriptNameReconstructsHebrewFont() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let batch = try #require(snapshot.presentedDocument.marks.compactMap
        {
            mark -> PresentationGlyphBatch? in
            guard case let .glyphs(batch) = mark,
                  batch.sourceSlices.map(\.text).joined() == "שלום"
            else
            {
                return nil
            }
            return batch
        }.first)
        #expect(batch.font.postScriptName == "TimesNewRomanPSMT")
        #expect(MacAdmittedFont(
            batch.font,
            sourceText: "שלום"
        ) != nil)
    }
}
