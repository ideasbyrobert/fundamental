extension PresentationComposer
{
    static func hardBreakX(
        _ caret: PresentedCaretSite, line: PresentedTextLine
    ) -> Double?
    {
        let extent = line.selectionExtent
        let x = caret.position.x
        if extent.minX ... extent.maxX ~= x
        {
            return x
        }
        let overshoot = extent.leading < extent.trailing
            ? x > extent.trailing : x < extent.trailing
        let beforeBreak = line.text.dropLast()
        var prefix = beforeBreak
        while let character = prefix.last,
              character.isWhitespace, !character.isNewline
        {
            prefix = prefix.dropLast()
        }
        let offset = line.firstCaretSite.sourcePoint.utf16Offset
            + prefix.utf16.count
        guard overshoot, prefix.utf16.count < beforeBreak.utf16.count,
              caret.sourcePoint.utf16Offset >= offset,
              let boundary = exactCaret(offset, line: line),
              extent.minX ... extent.maxX ~= boundary.position.x
        else
        {
            return nil
        }
        return extent.trailing
    }
}
