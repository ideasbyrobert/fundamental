@testable import FundamentalPresentation

extension MacRasterSnapshotFixture
{
    static func replacingFirstGlyphBatch(
        in snapshot: PresentationSnapshot,
        transform: (PresentationGlyphBatch) -> PresentationGlyphBatch
    ) -> PresentationSnapshot?
    {
        var marks = snapshot.presentedDocument.marks
        guard let index = marks.firstIndex(where:
        {
            if case .glyphs = $0
            {
                return true
            }
            return false
        }),
              case let .glyphs(batch) = marks[index]
        else
        {
            return nil
        }
        marks[index] = .glyphs(transform(batch))
        return replacingMarks(in: snapshot, with: marks)
    }

    static func replacingColorSpace(
        in snapshot: PresentationSnapshot,
        with colorSpace: PresentationColorSpaceIdentity
    ) -> PresentationSnapshot
    {
        let document = snapshot.presentedDocument
        let plane = document.plane
        let replaced = PresentationDocumentPlane(
            documentSize: plane.documentSize,
            logicalBounds: plane.logicalBounds,
            pixelBounds: plane.pixelBounds,
            backingScale: plane.backingScale,
            appearance: plane.appearance,
            colorSpace: colorSpace,
            palette: plane.palette
        )
        let result = PresentedDocument(
            lineage: document.lineage,
            storage: PresentedDocumentStorage(
                plane: replaced,
                sourceAnchor: document.sourceAnchor,
                residents: document.residents,
                marks: document.marks
            )
        )
        switch snapshot
        {
        case .document:
            return .document(result)
        case let .caret(_, caret):
            return .caret(result, caret)
        case let .selection(_, selection):
            return .selection(result, selection)
        }
    }

    static func glyphBatch(
        _ source: PresentationGlyphBatch,
        font: PresentationFontIdentity
    ) -> PresentationGlyphBatch
    {
        PresentationGlyphBatch(
            residentID: source.residentID,
            paintOrder: source.paintOrder,
            logicalBounds: source.logicalBounds,
            clipBounds: source.clipBounds,
            pixelBounds: source.pixelBounds,
            font: font,
            textMatrix: source.textMatrix,
            baselineOffset: source.baselineOffset,
            color: source.color,
            sourceSlices: source.sourceSlices,
            firstGlyph: source.firstGlyph,
            remainingGlyphs: source.remainingGlyphs
        )
    }
}
