import CoreGraphics
import FundamentalPresentation

extension MacRasterExecutor
{
    func drawSelection(
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

    func drawSelection(
        _ selection: MacAdmittedSelectionExecution,
        fragment: MacAdmittedSelectionFragment,
        in context: CGContext
    )
    {
        context.setFillColor(selection.color.graphics)
        context.fill(fragment.logicalBounds)
    }

    func drawCaret(
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
}
