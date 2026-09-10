import FundamentalPresentation

extension MacReaderModel
{
    static func verticalDistance(
        _ point: PresentationPoint,
        bounds: PresentationRectangle
    ) -> Double
    {
        if point.y < bounds.minY
        {
            return bounds.minY - point.y
        }
        if point.y > bounds.maxY
        {
            return point.y - bounds.maxY
        }
        return 0
    }

    static func textLine(
        _ content: PresentedResidentContent
    ) -> PresentedTextLine?
    {
        content.textLine
    }
}
