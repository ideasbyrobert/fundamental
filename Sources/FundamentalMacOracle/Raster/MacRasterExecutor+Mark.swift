import FundamentalPresentation

extension MacRasterExecutor
{
    func admit(
        _ mark: PresentationMark,
        origins: [PresentationResidentID: PresentationPoint],
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
            guard let origin = origins[batch.residentID]
            else
            {
                return nil
            }
            return admit(batch, origin: origin, colorSpace: colorSpace)
        }
    }
}
