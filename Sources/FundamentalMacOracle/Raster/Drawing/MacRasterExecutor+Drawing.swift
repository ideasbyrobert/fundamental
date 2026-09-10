import CoreGraphics

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
}
