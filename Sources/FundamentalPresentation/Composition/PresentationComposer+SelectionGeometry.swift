extension PresentationComposer
{
    static func selectionGeometry(
        _ value: PresentationSelectionLine
    ) -> (
        bounds: PresentationRectangle?,
        direction: PresentationSelectionDirection?
    )?
    {
        let lower = value.lowerCaret.sourcePoint.utf16Offset
        let upper = value.upperCaret.sourcePoint.utf16Offset
        let carets = value.line.caretSites.filter
        {
            let offset = $0.sourcePoint.utf16Offset
            return lower ... upper ~= offset
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
            if pair.1.position.x > pair.0.position.x
            {
                ascending = true
            }
            if pair.1.position.x < pair.0.position.x
            {
                descending = true
            }
        }
        guard !(ascending && descending)
        else
        {
            return nil
        }
        let direction: PresentationSelectionDirection?
        if ascending
        {
            direction = .ascending
        }
        else if descending
        {
            direction = .descending
        }
        else
        {
            direction = nil
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

    static func utf16Substring(
        _ value: String,
        range: Range<Int>
    ) -> String?
    {
        guard range.lowerBound >= 0,
              range.lowerBound < range.upperBound,
              range.upperBound <= value.utf16.count
        else
        {
            return nil
        }
        let utf16 = value.utf16
        let lowerUTF16 = utf16.index(
            utf16.startIndex,
            offsetBy: range.lowerBound
        )
        let upperUTF16 = utf16.index(
            utf16.startIndex,
            offsetBy: range.upperBound
        )
        guard let lower = String.Index(lowerUTF16, within: value),
              let upper = String.Index(upperUTF16, within: value)
        else
        {
            return nil
        }
        return String(value[lower ..< upper])
    }

    static func contiguous(
        _ slices: [PresentationSourceSlice]
    ) -> Bool
    {
        guard !slices.isEmpty
        else
        {
            return false
        }
        return zip(slices, slices.dropFirst()).allSatisfy
        {
            $0.range.upperBound == $1.range.lowerBound
                && $0.source.domain == $1.source.domain
        }
    }
}
