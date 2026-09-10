struct PresentationSelectionSpan
{
    let lower: PresentationTextPosition
    let upper: PresentationTextPosition
    let indices: ClosedRange<Int>

    init?(
        _ selection: PresentationTextSelection,
        residents: [PresentedResident]
    )
    {
        let anchor = selection.anchor.sourcePoint.utf16Offset
        let focus = selection.focus.sourcePoint.utf16Offset
        guard anchor != focus
        else
        {
            return nil
        }
        let lower = anchor < focus ? selection.anchor : selection.focus
        let upper = anchor < focus ? selection.focus : selection.anchor
        guard let first = residents.firstIndex(where:
        {
            $0.residentID == lower.residentID
        }),
              let last = residents.firstIndex(where:
              {
                  $0.residentID == upper.residentID
              }),
              first <= last
        else
        {
            return nil
        }
        self.lower = lower
        self.upper = upper
        indices = first ... last
    }
}
