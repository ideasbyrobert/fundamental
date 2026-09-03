import CoreGraphics
import CoreText
import FundamentalPresentation

extension MacRasterExecutor
{
    func draw(
        _ execution: MacAdmittedRasterExecution,
        in context: CGContext,
        horizontalInset: Double
    )
    {
        let document = execution.documentExecution
        context.saveGState()
        context.translateBy(x: horizontalInset, y: 0)
        context.setFillColor(document.background.graphics)
        context.fill(document.logicalBounds)
        drawMarks(execution, in: context)
        drawCaret(execution, in: context)
        context.restoreGState()
    }

    private func draw(
        _ mark: MacAdmittedRasterMark,
        in context: CGContext
    )
    {
        switch mark
        {
        case let .fill(fill):
            context.setFillColor(fill.color.graphics)
            context.fill(fill.logicalBounds)
        case let .glyphs(batch):
            context.saveGState()
            context.clip(to: batch.clipBounds)
            context.setFillColor(batch.color.graphics)
            context.setTextDrawingMode(.fill)
            context.textMatrix = Self.nativeTextMatrix
            CTFontDrawGlyphs(
                batch.font.native,
                batch.glyphs,
                batch.positions,
                batch.glyphs.count,
                context
            )
            context.restoreGState()
        }
    }

    private func drawMarks(
        _ execution: MacAdmittedRasterExecution,
        in context: CGContext
    )
    {
        var selectedResidents = Set<PresentationResidentID>()
        for mark in execution.documentExecution.marks
        {
            if case let .selection(_, _, selection) = execution,
               !selectedResidents.contains(mark.residentID)
            {
                drawSelection(
                    selection,
                    residentID: mark.residentID,
                    in: context
                )
                selectedResidents.insert(mark.residentID)
            }
            draw(mark, in: context)
        }
        guard case let .selection(_, _, selection) = execution
        else
        {
            return
        }
        for fragment in selection.fragments
            where !selectedResidents.contains(fragment.residentID)
        {
            drawSelection(
                selection,
                fragment: fragment,
                in: context
            )
        }
    }

    private func drawSelection(
        _ selection: MacAdmittedSelectionExecution,
        residentID: PresentationResidentID,
        in context: CGContext
    )
    {
        for fragment in selection.fragments
            where fragment.residentID == residentID
        {
            drawSelection(
                selection,
                fragment: fragment,
                in: context
            )
        }
    }

    private func drawSelection(
        _ selection: MacAdmittedSelectionExecution,
        fragment: MacAdmittedSelectionFragment,
        in context: CGContext
    )
    {
        context.setFillColor(selection.color.graphics)
        context.fill(fragment.logicalBounds)
    }

    private func drawCaret(
        _ execution: MacAdmittedRasterExecution,
        in context: CGContext
    )
    {
        guard case let .caret(_, _, caret) = execution
        else
        {
            return
        }
        context.setFillColor(caret.color.graphics)
        context.fill(caret.logicalBounds)
    }

    private static let nativeTextMatrix = CGAffineTransform(
        a: 1,
        b: 0,
        c: 0,
        d: -1,
        tx: 0,
        ty: 0
    )
}
