import CoreGraphics
import FundamentalPresentation

@MainActor
struct MacRasterExecutor
{
    func admit(
        _ snapshot: PresentationSnapshot
    ) -> MacAdmittedRasterExecution?
    {
        guard let document = admit(snapshot.presentedDocument)
        else
        {
            return nil
        }
        return admit(snapshot, document: document)
    }

    func admit(
        _ snapshot: PresentationSnapshot,
        reusing execution: MacAdmittedDocumentExecution
    ) -> MacAdmittedRasterExecution?
    {
        let document: MacAdmittedDocumentExecution
        if snapshot.presentedDocument.sharesStorage(
            with: execution.source
        )
        {
            document = execution
        }
        else
        {
            guard let admitted = admit(snapshot.presentedDocument)
            else
            {
                return nil
            }
            document = admitted
        }
        return admit(snapshot, document: document)
    }

    static func admitsTextMatrix(
        _ value: PresentationAffineTransform
    ) -> Bool
    {
        value.a == 1
            && value.b == 0
            && value.c == 0
            && value.d == 1
            && value.tx == 0
            && value.ty == 0
    }

    private func admit(
        _ document: PresentedDocument
    ) -> MacAdmittedDocumentExecution?
    {
        guard let colorSpace = MacAdmittedColorSpace(
            document.plane.colorSpace
        ),
              let background = MacAdmittedColor(
                  document.plane.palette.documentBackground,
                  colorSpace: colorSpace
              )
        else
        {
            return nil
        }
        var marks: [MacAdmittedRasterMark] = []
        marks.reserveCapacity(document.marks.count)
        for mark in document.marks
        {
            guard let admitted = admit(mark, colorSpace: colorSpace)
            else
            {
                return nil
            }
            marks.append(admitted)
        }
        return MacAdmittedDocumentExecution(
            source: document,
            colorSpace: colorSpace,
            background: background,
            logicalBounds: Self.rectangle(document.plane.logicalBounds),
            marks: marks
        )
    }

    private func admit(
        _ snapshot: PresentationSnapshot,
        document: MacAdmittedDocumentExecution
    ) -> MacAdmittedRasterExecution?
    {
        let lineage = snapshot.lineage
        switch snapshot
        {
        case .document:
            return .document(
                lineage: lineage,
                document: document
            )
        case let .caret(_, caret):
            guard let admitted = admit(
                caret,
                colorSpace: document.colorSpace
            )
            else
            {
                return nil
            }
            return .caret(
                lineage: lineage,
                document: document,
                caret: admitted
            )
        case let .selection(_, selection):
            guard let admitted = admit(
                selection,
                colorSpace: document.colorSpace
            )
            else
            {
                return nil
            }
            return .selection(
                lineage: lineage,
                document: document,
                selection: admitted
            )
        }
    }

    private func admit(
        _ mark: PresentationMark,
        colorSpace: MacAdmittedColorSpace
    ) -> MacAdmittedRasterMark?
    {
        switch mark
        {
        case let .fill(fill):
            guard let color = MacAdmittedColor(
                fill.color,
                colorSpace: colorSpace
            )
            else
            {
                return nil
            }
            return .fill(MacAdmittedFillExecution(
                residentID: fill.residentID,
                color: color,
                logicalBounds: Self.rectangle(fill.logicalBounds)
            ))
        case let .glyphs(batch):
            return admit(batch, colorSpace: colorSpace)
        }
    }

    private func admit(
        _ batch: PresentationGlyphBatch,
        colorSpace: MacAdmittedColorSpace
    ) -> MacAdmittedRasterMark?
    {
        guard Self.admitsTextMatrix(batch.textMatrix),
              batch.glyphs.allSatisfy(
                  { $0.identifier <= UInt16.max }
              ),
              let font = MacAdmittedFont(
                  batch.font,
                  sourceText: Self.sourceText(batch)
              ),
              let color = MacAdmittedColor(
                  batch.color,
                  colorSpace: colorSpace
              )
        else
        {
            return nil
        }
        return .glyphs(MacAdmittedGlyphExecution(
            residentID: batch.residentID,
            font: font,
            color: color,
            glyphs: batch.glyphs.map
            {
                CGGlyph($0.identifier)
            },
            positions: batch.glyphs.map
            {
                CGPoint(x: $0.position.x, y: -$0.position.y)
            },
            clipBounds: Self.rectangle(batch.clipBounds)
        ))
    }

    private func admit(
        _ caret: PresentationCaretAdornment,
        colorSpace: MacAdmittedColorSpace
    ) -> MacAdmittedCaretExecution?
    {
        guard let color = MacAdmittedColor(
            caret.color,
            colorSpace: colorSpace
        )
        else
        {
            return nil
        }
        return MacAdmittedCaretExecution(
            source: caret,
            color: color,
            logicalBounds: Self.rectangle(caret.logicalBounds)
        )
    }

    private func admit(
        _ selection: PresentationSelectionAdornment,
        colorSpace: MacAdmittedColorSpace
    ) -> MacAdmittedSelectionExecution?
    {
        guard let color = MacAdmittedColor(
            selection.color,
            colorSpace: colorSpace
        )
        else
        {
            return nil
        }
        let fragments = selection.fragments.map
        {
            MacAdmittedSelectionFragment(
                residentID: $0.residentID,
                logicalBounds: Self.rectangle($0.logicalBounds)
            )
        }
        guard let first = fragments.first
        else
        {
            return nil
        }
        return MacAdmittedSelectionExecution(
            source: selection,
            color: color,
            firstFragment: first,
            remainingFragments: Array(fragments.dropFirst())
        )
    }

    private static func rectangle(
        _ value: PresentationRectangle
    ) -> CGRect
    {
        CGRect(
            x: value.origin.x,
            y: value.origin.y,
            width: value.size.width,
            height: value.size.height
        )
    }

    private static func sourceText(
        _ batch: PresentationGlyphBatch
    ) -> String
    {
        batch.sourceSlices.map(\.text).joined()
    }
}
