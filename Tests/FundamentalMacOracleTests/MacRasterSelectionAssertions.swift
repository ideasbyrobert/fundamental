import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

extension MacRasterExecutorTests
{
    func assertSelectionOrder(
        model: MacReaderModel,
        resident: PresentedResident,
        line: PresentedTextLine
    ) throws
    {
        let first = try #require(line.caretSites.first)
        let last = try #require(line.caretSites.last)
        let anchor = PresentationTextPosition(
            residentID: resident.residentID,
            sourcePoint: first.sourcePoint
        )
        let focus = PresentationTextPosition(
            residentID: resident.residentID,
            sourcePoint: last.sourcePoint
        )
        #expect(model.showSelection(anchor: anchor, focus: focus))
        guard case let .selection(_, selection) = model.snapshot
        else
        {
            throw MacOracleTestFailure.admission
        }
        let selected = model.snapshot
        let reference = MacRasterSnapshotFixture.documentOnly(selected)
        let marks = selected.presentedDocument.marks.filter
        {
            guard case .glyphs = $0,
                  $0.residentID == resident.residentID
            else
            {
                return true
            }
            return false
        }
        let withoutGlyphs = MacRasterSnapshotFixture.replacingMarks(
            in: selected,
            with: marks
        )
        let referenceSurface = try #require(MacBitmapSurface(reference))
        let selectedSurface = try #require(MacBitmapSurface(selected))
        let noGlyphSurface = try #require(MacBitmapSurface(withoutGlyphs))
        #expect(referenceSurface.draw(reference))
        #expect(selectedSurface.draw(selected))
        #expect(noGlyphSurface.draw(withoutGlyphs))
        for fragment in selection.fragments
        {
            let bounds = try #require(PresentationPixelBounds(
                logicalBounds: fragment.logicalBounds,
                backingScale: selected.presentedDocument.plane.backingScale
            ))
            #expect(!selectedSurface.changedPixels(
                from: referenceSurface,
                in: bounds
            ).isEmpty)
            #expect(!selectedSurface.changedPixels(
                from: noGlyphSurface,
                in: bounds
            ).isEmpty)
        }
    }
}
