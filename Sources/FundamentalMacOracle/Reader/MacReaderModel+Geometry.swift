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
        switch content
        {
        case let .body(line),
             let .title(line),
             let .code(line),
             let .caption(line):
            return line
        case let .section(_, line):
            return line
        case let .headerCell(_, _, .line(line)),
             let .bodyCell(_, _, .line(line)):
            return line
        case .table,
             .tableColumn,
             .headerRow,
             .bodyRow,
             .headerCell(_, _, .area),
             .bodyCell(_, _, .area):
            return nil
        }
    }
}
