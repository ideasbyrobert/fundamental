extension PresentationComposer
{
    static func selectionAdvance(
        _ value: PresentationSelectionLine
    ) -> (ascending: Bool, descending: Bool)?
    {
        let lower = value.lowerCaret.sourcePoint.utf16Offset
        let upper = value.upperCaret.sourcePoint.utf16Offset
        let carets = value.line.caretSites.filter
        {
            lower ... upper ~= $0.sourcePoint.utf16Offset
        }
        guard carets.first == value.lowerCaret,
              carets.last == value.upperCaret
        else
        {
            return nil
        }
        var ascending = false
        var descending = false
        for pair in zip(carets, carets.dropFirst())
        {
            ascending = ascending || pair.1.position.x > pair.0.position.x
            descending = descending || pair.1.position.x < pair.0.position.x
        }
        return ascending && descending ? nil : (ascending, descending)
    }

    static func selectsTerminalBreak(
        _ value: PresentationSelectionLine
    ) -> Bool
    {
        value.line.text.last?.isNewline == true
            && value.upperCaret == value.line.caretSites.last
            && value.lowerCaret.sourcePoint.utf16Offset
                < value.upperCaret.sourcePoint.utf16Offset
    }
}
