extension PresentationComposer
{
    static func selectedText(
        _ value: PresentationSelectionLine
    ) -> String?
    {
        let lineStart = value.line.firstCaretSite
            .sourcePoint.utf16Offset
        let range = value.lowerCaret.sourcePoint.utf16Offset - lineStart
            ..< value.upperCaret.sourcePoint.utf16Offset - lineStart
        return utf16Substring(value.line.text, range: range)
    }

    static func selectedSlices(
        _ value: PresentationSelectionLine
    ) -> [PresentationSourceSlice]?
    {
        let lower = value.lowerCaret.sourcePoint.utf16Offset
        let upper = value.upperCaret.sourcePoint.utf16Offset
        var result: [PresentationSourceSlice] = []
        for slice in value.line.sourceSlices
        {
            let sliceLower = max(lower, slice.range.lowerBound)
            let sliceUpper = min(upper, slice.range.upperBound)
            guard sliceLower < sliceUpper
            else
            {
                continue
            }
            let localRange = sliceLower - slice.range.lowerBound
                ..< sliceUpper - slice.range.lowerBound
            guard let text = utf16Substring(
                slice.text,
                range: localRange
            )
            else
            {
                return nil
            }
            result.append(PresentationSourceSlice(
                source: slice.source,
                scope: slice.scope,
                range: sliceLower ..< sliceUpper,
                text: text
            ))
        }
        return result
    }

}
