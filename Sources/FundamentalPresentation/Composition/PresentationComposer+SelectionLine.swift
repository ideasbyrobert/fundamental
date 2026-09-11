extension PresentationComposer
{
    static func selectionLine(
        _ resident: PresentedResident, span: PresentationSelectionSpan,
        index: Int, precedingUpper: Int?
    ) -> (line: PresentationSelectionLine?, upper: Int)?
    {
        guard let line = residentText(resident.content),
              line.firstCaretSite.sourcePoint.domain
                == span.lower.sourcePoint.domain,
              let first = line.caretSites.first,
              let last = line.caretSites.last,
              first.sourcePoint.utf16Offset <= last.sourcePoint.utf16Offset,
              precedingUpper == nil
                || precedingUpper == first.sourcePoint.utf16Offset
        else
        {
            return nil
        }
        let lowerOffset = max(
            span.lower.sourcePoint.utf16Offset,
            first.sourcePoint.utf16Offset
        )
        let upperOffset = min(
            span.upper.sourcePoint.utf16Offset,
            last.sourcePoint.utf16Offset
        )
        guard lowerOffset <= upperOffset,
              let lower = exactCaret(lowerOffset, line: line),
              let upper = exactCaret(upperOffset, line: line),
              index != span.indices.lowerBound
                || lower.sourcePoint == span.lower.sourcePoint,
              index != span.indices.upperBound
                || upper.sourcePoint == span.upper.sourcePoint
        else
        {
            return nil
        }
        if lowerOffset == upperOffset
        {
            let beginsAfter = index == span.indices.lowerBound
                && lower == last
            let endsBefore = index == span.indices.upperBound
                && upper == first
            guard beginsAfter || endsBefore
            else
            {
                return nil
            }
            return (nil, last.sourcePoint.utf16Offset)
        }
        return (
            PresentationSelectionLine(
                residentID: resident.residentID,
                isCode: isCode(resident.content), line: line,
                lowerCaret: lower, upperCaret: upper
            ),
            last.sourcePoint.utf16Offset
        )
    }

    static func isCode(_ content: PresentedResidentContent) -> Bool
    {
        if case .code = content
        {
            return true
        }
        return false
    }

    static func exactCaret(
        _ offset: Int, line: PresentedTextLine
    ) -> PresentedCaretSite?
    {
        let matches = line.caretSites.filter
        {
            $0.sourcePoint.utf16Offset == offset
        }
        guard matches.count == 1
        else
        {
            return nil
        }
        return matches[0]
    }
}
