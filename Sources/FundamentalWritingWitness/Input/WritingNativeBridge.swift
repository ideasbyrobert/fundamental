import AppKit
import FundamentalDocument

@MainActor
final class WritingNativeBridge: NSObject, NSTextViewDelegate
{
    let session: DocumentSession
    private(set) var projection: WritingProjection
    private var projecting = false

    init?(session: DocumentSession)
    {
        guard let projection = WritingProjection(session.state)
        else
        {
            return nil
        }
        self.session = session
        self.projection = projection
    }

    @discardableResult
    func project(in view: NSTextView) -> Bool
    {
        guard view.textLayoutManager != nil,
              let next = WritingProjection(session.state)
        else
        {
            return false
        }
        projecting = true
        defer
        {
            projecting = false
        }
        projection = next
        view.string = next.text
        view.setSelectedRange(next.selection)
        view.scrollRangeToVisible(next.selection)
        return true
    }

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

    func textView(
        _ textView: NSTextView,
        willChangeSelectionFromCharacterRanges oldRanges: [NSValue],
        toCharacterRanges newRanges: [NSValue]
    ) -> [NSValue]
    {
        guard !projecting
        else
        {
            return newRanges
        }
        guard newRanges.count == 1,
              projection.range(newRanges[0].rangeValue) != nil
        else
        {
            return [NSValue(range: projection.selection)]
        }
        return newRanges
    }

    func textViewDidChangeSelection(_ notification: Notification)
    {
        guard !projecting, let view = notification.object as? NSTextView
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
            }
        case .refused:
            project(in: view)
        }
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

    @discardableResult
    func move(
        _ direction: DocumentHistoryDirection,
        in view: NSTextView
    ) -> DocumentSessionTransition
    {
        guard view.textLayoutManager != nil
        else
        {
            return .refused(.invalidCommand)
        }
        let result = session.submit(DocumentHistoryCommand(
            observation: projection.observation,
            direction: direction
        ))
        project(in: view)
        return result
    }

    func copy(to pasteboard: NSPasteboard, from view: NSTextView) -> Bool
    {
        guard project(in: view), projection.selection.length > 0
        else
        {
            return false
        }
        let text = (projection.text as NSString).substring(
            with: projection.selection
        )
        pasteboard.clearContents()
        return pasteboard.setString(text, forType: .string)
    }
}
