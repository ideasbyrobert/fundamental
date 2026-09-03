import FundamentalRaster

extension PresentationComposer
{
    static func textLine(
        _ value: RasterInteractionText
    ) -> PresentedTextLine?
    {
        guard let font = font(value.defaultFont),
              let bounds = rectangle(value.lineBounds),
              bounds.size.height > 0,
              let baseline = point(value.baseline),
              let slices = sourceSlices(value.sourceSlices),
              let firstCaret = caretSite(value.firstCaretSite)
        else
        {
            return nil
        }
        var carets = [firstCaret]
        carets.reserveCapacity(1 + value.remainingCaretSites.count)
        for value in value.remainingCaretSites
        {
            guard let caret = caretSite(value)
            else
            {
                return nil
            }
            carets.append(caret)
        }
        guard validText(
            value.text,
            slices: slices,
            carets: carets
        )
        else
        {
            return nil
        }
        return PresentedTextLine(
            text: value.text,
            defaultFont: font,
            lineBounds: bounds,
            baseline: baseline,
            sourceSlices: slices,
            firstCaretSite: firstCaret,
            remainingCaretSites: Array(carets.dropFirst())
        )
    }

    static func caretSite(
        _ value: RasterCaretSite
    ) -> PresentedCaretSite?
    {
        guard value.utf16Offset >= 0,
              let position = point(value.position),
              let sourcePoint = textPoint(value.sourcePoint)
        else
        {
            return nil
        }
        return PresentedCaretSite(
            utf16Offset: value.utf16Offset,
            position: position,
            sourcePoint: sourcePoint
        )
    }

    static func validText(
        _ text: String,
        slices: [PresentationSourceSlice],
        carets: [PresentedCaretSite]
    ) -> Bool
    {
        guard let firstCaret = carets.first,
              let lastCaret = carets.last,
              firstCaret.utf16Offset == 0,
              lastCaret.utf16Offset == text.utf16.count,
              carets.map(\.utf16Offset) == characterOffsets(text),
              carets.allSatisfy(
                  { $0.sourcePoint.domain == firstCaret.sourcePoint.domain }
              ),
              carets.allSatisfy(
                  {
                      $0.sourcePoint.utf16Offset
                        == firstCaret.sourcePoint.utf16Offset
                            + $0.utf16Offset
                  }
              )
        else
        {
            return false
        }
        if text.isEmpty
        {
            return slices.isEmpty
        }
        guard !slices.isEmpty,
              slices.map(\.text).joined() == text,
              slices.allSatisfy(
                  { $0.source.domain == firstCaret.sourcePoint.domain }
              ),
              slices.first?.range.lowerBound
                == firstCaret.sourcePoint.utf16Offset,
              slices.last?.range.upperBound
                == lastCaret.sourcePoint.utf16Offset
        else
        {
            return false
        }
        return zip(slices, slices.dropFirst()).allSatisfy
        {
            $0.range.upperBound == $1.range.lowerBound
        }
    }

    static func characterOffsets(_ value: String) -> [Int]
    {
        var result = [0]
        var offset = 0
        for character in value
        {
            offset += String(character).utf16.count
            result.append(offset)
        }
        return result
    }
}
