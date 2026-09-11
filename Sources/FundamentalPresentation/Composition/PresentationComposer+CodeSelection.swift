extension PresentationComposer
{
    static func completeCodeGeometry(
        _ value: PresentationSelectionLine
    ) -> (
        bounds: PresentationRectangle?,
        direction: PresentationSelectionDirection?
    )?
    {
        let line = value.line
        let extent = line.selectionExtent
        let start = line.lineBounds.minX
        let end = selectsTerminalBreak(value)
            ? extent.trailing : line.lineBounds.maxX
        guard extent.leading < extent.trailing,
              extent.minX ... extent.maxX ~= start,
              extent.minX ... extent.maxX ~= end
        else
        {
            return nil
        }
        if start == end
        {
            return (nil, nil)
        }
        guard let bounds = rectangle(
            x: start, y: line.lineBounds.minY, width: end - start,
            height: line.lineBounds.size.height
        )
        else
        {
            return nil
        }
        return (bounds, .ascending)
    }
}
