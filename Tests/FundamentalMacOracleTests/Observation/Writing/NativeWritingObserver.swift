import AppKit

@MainActor
final class NativeWritingObserver: NSObject, NSTextViewDelegate
{
    var observations: [NativeWritingObservation] = []
    var admission: NativeWritingAdmission = .permit

    func textView(
        _ textView: NSTextView,
        shouldChangeTextInRanges ranges: [NSValue],
        replacementStrings: [String]?
    ) -> Bool
    {
        observations.append(.proposal(
            ranges: ranges.map(\.rangeValue),
            replacements: replacementStrings?.map { Array($0.utf16) },
            spelling: Array(textView.string.utf16),
            selection: textView.selectedRange(),
            marked: textView.markedRange()
        ))
        switch admission
        {
        case .permit:
            return true
        case .refuse:
            return false
        case let .reconstruct(spelling, selection):
            textView.string = spelling
            textView.setSelectedRange(selection)
            return false
        }
    }

    func textDidChange(_ notification: Notification)
    {
        guard let view = notification.object as? NSTextView
        else
        {
            return
        }
        observations.append(.changed(Array(view.string.utf16)))
    }

    func textViewDidChangeSelection(_ notification: Notification)
    {
        guard let view = notification.object as? NSTextView
        else
        {
            return
        }
        observations.append(.selected(view.selectedRange()))
    }
}
