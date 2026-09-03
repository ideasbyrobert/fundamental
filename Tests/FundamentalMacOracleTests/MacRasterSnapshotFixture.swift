@testable import FundamentalMacOracle
@testable import FundamentalPresentation

enum MacRasterSnapshotFixture
{
    static func replacingMarks(
        in snapshot: PresentationSnapshot,
        with marks: [PresentationMark]
    ) -> PresentationSnapshot
    {
        let source = snapshot.presentedDocument
        let document = PresentedDocument(
            lineage: source.lineage,
            storage: PresentedDocumentStorage(
                plane: source.plane,
                sourceAnchor: source.sourceAnchor,
                residents: source.residents,
                marks: marks
            )
        )
        switch snapshot
        {
        case .document:
            return .document(document)
        case let .caret(_, caret):
            return .caret(document, caret)
        case let .selection(_, selection):
            return .selection(document, selection)
        }
    }

    static func replacingFirstMatrix(
        in snapshot: PresentationSnapshot,
        with transform: PresentationAffineTransform
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
        marks[index] = .glyphs(glyphBatch(
            batch,
            transform: transform
        ))
        return replacingMarks(in: snapshot, with: marks)
    }

    static func documentOnly(
        _ snapshot: PresentationSnapshot
    ) -> PresentationSnapshot
    {
        .document(snapshot.presentedDocument)
    }

    static func glyphBatch(
        _ source: PresentationGlyphBatch,
        transform: PresentationAffineTransform
    ) -> PresentationGlyphBatch
    {
        PresentationGlyphBatch(
            residentID: source.residentID,
            paintOrder: source.paintOrder,
            logicalBounds: source.logicalBounds,
            clipBounds: source.clipBounds,
            pixelBounds: source.pixelBounds,
            font: source.font,
            textMatrix: transform,
            baselineOffset: source.baselineOffset,
            color: source.color,
            sourceSlices: source.sourceSlices,
            firstGlyph: source.firstGlyph,
            remainingGlyphs: source.remainingGlyphs
        )
    }
}
