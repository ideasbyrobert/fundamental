extension PresentationComposer
{
    static func selectionGeometry(
        _ value: PresentationSelectionLine, minimumWidth: Double
    ) -> (
        bounds: PresentationRectangle?,
        direction: PresentationSelectionDirection?
    )?
    {
        if value.isCode,
           value.lowerCaret == value.line.firstCaretSite,
           value.upperCaret == value.line.caretSites.last
        {
            return completeCodeGeometry(value)
        }
        guard let advance = selectionAdvance(value)
        else
        {
            return nil
        }
        let direction: PresentationSelectionDirection? = advance.ascending
            ? .ascending : (advance.descending ? .descending : nil)
        if selectsTerminalBreak(value)
        {
            return hardBreakGeometry(
                value, direction: direction, minimumWidth: minimumWidth
            )
        }
        let width = abs(
            value.upperCaret.position.x - value.lowerCaret.position.x
        )
        guard width > 0,
              let bounds = rectangle(
                  x: min(
                      value.lowerCaret.position.x,
                      value.upperCaret.position.x
                  ),
                  y: value.line.lineBounds.minY,
                  width: width,
                  height: value.line.lineBounds.size.height
              )
        else
        {
            return (nil, nil)
        }
        return (bounds, direction)
    }
}
