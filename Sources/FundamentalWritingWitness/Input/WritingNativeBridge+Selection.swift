import AppKit

extension WritingNativeBridge
{
    func textView(
        _ textView: NSTextView,
        willChangeSelectionFromCharacterRanges oldRanges: [NSValue],
        toCharacterRanges newRanges: [NSValue]
    ) -> [NSValue]
    {
        guard !projecting, !composing
        else
        {
            return newRanges
        }
        guard finishComposition(in: textView), newRanges.count == 1,
              projection.range(newRanges[0].rangeValue) != nil
        else
        {
            return [NSValue(range: projection.selection)]
        }
        return newRanges
    }

    func textViewDidChangeSelection(_ notification: Notification)
    {
        guard !projecting, !composing,
              let view = notification.object as? NSTextView
        else
        {
            return
        }
        guard view.textLayoutManager != nil,
              view.string.utf16.elementsEqual(projection.text.utf16),
              let proposal = WritingSelectionProposal(
                  ranges: view.selectedRanges.map(\.rangeValue),
                  in: projection
              )
        else
        {
            project(in: view)
            return
        }
        switch session.submit(proposal.command)
        {
        case .applied, .unchanged:
            if let next = WritingProjection(session.state)
            {
                projection = next
                updateTyping(in: view)
                didChange?()
            }
        case .refused:
            project(in: view)
        }
    }
}
