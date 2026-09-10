import CoreGraphics
import FundamentalPresentation

extension MacRasterExecutor
{
    func drawMarks(
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
}
