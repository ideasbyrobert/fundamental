import AppKit

extension WritingNativeBridge
{
    func textView(
        _ textView: NSTextView,
        shouldChangeTextInRanges ranges: [NSValue],
        replacementStrings: [String]?
    ) -> Bool
    {
        guard !projecting, textView.textLayoutManager != nil
        else
        {
            return false
        }
        guard textView.string.utf16.elementsEqual(projection.text.utf16),
              let proposal = WritingTextProposal(
                  ranges: ranges.map(\.rangeValue),
                  replacements: replacementStrings,
                  in: projection
              )
        else
        {
            project(in: textView)
            return false
        }
        session.submit(proposal.command)
        project(in: textView)
        return false
    }

    func textDidChange(_ notification: Notification)
    {
        guard !projecting, let view = notification.object as? NSTextView
        else
        {
            return
        }
        project(in: view)
    }
}
