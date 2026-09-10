import FundamentalRaster

extension PresentationComposer
{
    static func caretSite(
        _ value: RasterCaretSite
    ) -> PresentedCaretSite?
    {
        guard value.utf16Offset >= 0,
              let position = point(value.position),
              let sourcePoint = textPoint(value.sourcePoint)
        else
        {
            return nil
        }
        return PresentedCaretSite(
            utf16Offset: value.utf16Offset,
            position: position,
            sourcePoint: sourcePoint
        )
    }
}
