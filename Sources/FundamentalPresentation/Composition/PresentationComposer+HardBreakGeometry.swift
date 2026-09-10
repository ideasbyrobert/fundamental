extension PresentationComposer
{
    static func hardBreakGeometry(
        _ value: PresentationSelectionLine,
        direction: PresentationSelectionDirection?, minimumWidth: Double
    ) -> (
        bounds: PresentationRectangle?,
        direction: PresentationSelectionDirection?
    )?
    {
        let extent = value.line.selectionExtent
        let resolved: PresentationSelectionDirection =
            extent.trailing > extent.leading ? .ascending : .descending
        guard extent.minX < extent.maxX,
              direction == nil || direction == resolved,
              let start = hardBreakX(value.lowerCaret, line: value.line),
              let end = hardBreakX(value.upperCaret, line: value.line)
        else
        {
            return nil
        }
        var left = min(start, end, extent.trailing)
        var right = max(start, end, extent.trailing)
        if left == right
        {
            let width = min(minimumWidth, extent.maxX - extent.minX)
            if resolved == .ascending
            {
                left -= width
            }
            else
            {
                right += width
            }
        }
        guard right > left,
              let bounds = rectangle(
                  x: left, y: value.line.lineBounds.minY,
                  width: right - left,
                  height: value.line.lineBounds.size.height
              )
        else
        {
            return nil
        }
        return (bounds, resolved)
    }
}
