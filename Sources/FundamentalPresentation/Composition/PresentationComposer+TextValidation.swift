extension PresentationComposer
{
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
}
