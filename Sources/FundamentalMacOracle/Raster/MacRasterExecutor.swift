import AppKit
import CoreGraphics
import CoreText
import FundamentalPresentation

@MainActor
package struct MacRasterExecutor
{
    package init()
    {
    }

    package func admits(
        _ snapshot: PresentationSnapshot
    ) -> Bool
    {
        guard let colorSpace = MacAdmittedColorSpace(
            snapshot.presentedDocument.plane.colorSpace
        ),
              MacAdmittedColor(
                  snapshot.presentedDocument.plane.palette
                    .documentBackground,
                  colorSpace: colorSpace
              ) != nil
        else
        {
            return false
        }
        return preflight(snapshot, colorSpace: colorSpace)
    }

    @discardableResult
    package func draw(
        _ snapshot: PresentationSnapshot,
        in context: CGContext,
        horizontalInset: Double
    ) -> Bool
    {
        let document = snapshot.presentedDocument
        guard admits(snapshot),
              let colorSpace = MacAdmittedColorSpace(
                  document.plane.colorSpace
              ),
              let background = MacAdmittedColor(
                  document.plane.palette.documentBackground,
                  colorSpace: colorSpace
              )
        else
        {
            return false
        }
        context.saveGState()
        context.translateBy(x: horizontalInset, y: 0)
        context.setFillColor(background.graphics)
        context.fill(Self.rectangle(document.plane.logicalBounds))
        guard drawMarks(
            snapshot,
            colorSpace: colorSpace,
            in: context
        )
        else
        {
            context.restoreGState()
            return false
        }
        let drewCaret = drawCaret(
            snapshot,
            colorSpace: colorSpace,
            in: context
        )
        context.restoreGState()
        return drewCaret
    }

    private func preflight(
        _ snapshot: PresentationSnapshot,
        colorSpace: MacAdmittedColorSpace
    ) -> Bool
    {
        let marksAreAdmitted = snapshot.presentedDocument.marks.allSatisfy
        {
            mark in
            switch mark
            {
            case let .fill(fill):
                return MacAdmittedColor(
                    fill.color,
                    colorSpace: colorSpace
                ) != nil
            case let .glyphs(batch):
                return MacAdmittedFont(
                    batch.font,
                    sourceText: Self.sourceText(batch)
                ) != nil
                    && MacAdmittedColor(
                        batch.color,
                        colorSpace: colorSpace
                    ) != nil
                    && batch.glyphs.allSatisfy
                    {
                        $0.identifier <= UInt16.max
                    }
                    && Self.admitsTextMatrix(batch.textMatrix)
            }
        }
        guard marksAreAdmitted
        else
        {
            return false
        }
        switch snapshot
        {
        case .document:
            return true
        case let .caret(_, caret):
            return MacAdmittedColor(
                caret.color,
                colorSpace: colorSpace
            ) != nil
        case let .selection(_, selection):
            return MacAdmittedColor(
                selection.color,
                colorSpace: colorSpace
            ) != nil
        }
    }

    private func draw(
        _ mark: PresentationMark,
        colorSpace: MacAdmittedColorSpace,
        in context: CGContext
    ) -> Bool
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
                return false
            }
            context.setFillColor(color.graphics)
            context.fill(Self.rectangle(fill.logicalBounds))
            return true
        case let .glyphs(batch):
            return draw(
                batch,
                colorSpace: colorSpace,
                in: context
            )
        }
    }

    private func draw(
        _ batch: PresentationGlyphBatch,
        colorSpace: MacAdmittedColorSpace,
        in context: CGContext
    ) -> Bool
    {
        guard let font = MacAdmittedFont(
            batch.font,
            sourceText: Self.sourceText(batch)
        ),
              let color = MacAdmittedColor(
                  batch.color,
                  colorSpace: colorSpace
              ),
              batch.glyphs.allSatisfy(
                  { $0.identifier <= UInt16.max }
              )
        else
        {
            return false
        }
        let glyphs = batch.glyphs.map
        {
            CGGlyph($0.identifier)
        }
        let positions = batch.glyphs.map
        {
            CGPoint(x: $0.position.x, y: -$0.position.y)
        }
        context.saveGState()
        context.clip(to: Self.rectangle(batch.clipBounds))
        context.setFillColor(color.graphics)
        context.setTextDrawingMode(.fill)
        context.textMatrix = Self.nativeTextMatrix
        CTFontDrawGlyphs(
            font.native,
            glyphs,
            positions,
            glyphs.count,
            context
        )
        context.restoreGState()
        return true
    }

    private func drawMarks(
        _ snapshot: PresentationSnapshot,
        colorSpace: MacAdmittedColorSpace,
        in context: CGContext
    ) -> Bool
    {
        var selectedResidents = Set<PresentationResidentID>()
        for mark in snapshot.presentedDocument.marks
        {
            if case let .selection(_, selection) = snapshot,
               !selectedResidents.contains(mark.residentID)
            {
                guard drawSelection(
                    selection,
                    residentID: mark.residentID,
                    colorSpace: colorSpace,
                    in: context
                )
                else
                {
                    return false
                }
                selectedResidents.insert(mark.residentID)
            }
            guard draw(mark, colorSpace: colorSpace, in: context)
            else
            {
                return false
            }
        }
        guard case let .selection(_, selection) = snapshot
        else
        {
            return true
        }
        for fragment in selection.fragments
            where !selectedResidents.contains(fragment.residentID)
        {
            guard drawSelection(
                selection,
                fragment: fragment,
                colorSpace: colorSpace,
                in: context
            )
            else
            {
                return false
            }
        }
        return true
    }

    private func drawSelection(
        _ selection: PresentationSelectionAdornment,
        residentID: PresentationResidentID,
        colorSpace: MacAdmittedColorSpace,
        in context: CGContext
    ) -> Bool
    {
        for fragment in selection.fragments
            where fragment.residentID == residentID
        {
            guard drawSelection(
                selection,
                fragment: fragment,
                colorSpace: colorSpace,
                in: context
            )
            else
            {
                return false
            }
        }
        return true
    }

    private func drawSelection(
        _ selection: PresentationSelectionAdornment,
        fragment: PresentationSelectionFragment,
        colorSpace: MacAdmittedColorSpace,
        in context: CGContext
    ) -> Bool
    {
        guard let color = MacAdmittedColor(
            selection.color,
            colorSpace: colorSpace
        )
        else
        {
            return false
        }
        context.setFillColor(color.graphics)
        context.fill(Self.rectangle(fragment.logicalBounds))
        return true
    }

    private func drawCaret(
        _ snapshot: PresentationSnapshot,
        colorSpace: MacAdmittedColorSpace,
        in context: CGContext
    ) -> Bool
    {
        switch snapshot
        {
        case .document,
             .selection:
            return true
        case let .caret(_, caret):
            guard let color = MacAdmittedColor(
                caret.color,
                colorSpace: colorSpace
            )
            else
            {
                return false
            }
            context.setFillColor(color.graphics)
            context.fill(Self.rectangle(caret.logicalBounds))
            return true
        }
    }

    package static func admitsTextMatrix(
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

    private static let nativeTextMatrix = CGAffineTransform(
        a: 1,
        b: 0,
        c: 0,
        d: -1,
        tx: 0,
        ty: 0
    )

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
