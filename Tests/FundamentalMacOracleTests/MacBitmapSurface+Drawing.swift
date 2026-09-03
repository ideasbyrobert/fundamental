import FundamentalPresentation

@testable import FundamentalMacOracle

extension MacBitmapSurface
{
    func draw(
        _ snapshot: PresentationSnapshot
    ) -> Bool
    {
        let executor = MacRasterExecutor()
        guard let execution = executor.admit(snapshot)
        else
        {
            return false
        }
        draw(execution, using: executor)
        return true
    }

    func draw(
        _ execution: MacAdmittedRasterExecution
    )
    {
        draw(execution, using: MacRasterExecutor())
    }

    private func draw(
        _ execution: MacAdmittedRasterExecution,
        using executor: MacRasterExecutor
    )
    {
        let logicalHeight = Double(height) / backingScale
        context.saveGState()
        context.scaleBy(x: backingScale, y: backingScale)
        context.translateBy(
            x: -logicalMinimumX,
            y: logicalMinimumY + logicalHeight
        )
        context.scaleBy(x: 1, y: -1)
        executor.draw(
            execution,
            in: context,
            horizontalInset: 0
        )
        context.restoreGState()
        context.flush()
    }
}
