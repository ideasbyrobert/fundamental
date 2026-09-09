import AppKit
import FundamentalDocument

extension WritingNativeBridge
{
    func formattingRange(in view: NSTextView) -> DocumentRange?
    {
        guard view.textLayoutManager != nil, finishComposition(in: view),
              view.string.utf16.elementsEqual(projection.text.utf16),
              let range = projection.range(view.selectedRange())
        else
        {
            project(in: view)
            return nil
        }
        return range
    }

    @discardableResult
    func submitFormatting(
        _ command: DocumentSessionCommand, in view: NSTextView
    ) -> DocumentSessionTransition
    {
        defer
        {
            project(in: view)
            view.window?.makeFirstResponder(view)
        }
        let preview = DocumentSessionTransition(command, in: session.state)
        guard case let .applied(successor) = preview
        else
        {
            return preview
        }
        guard WritingProjection(successor) != nil
        else
        {
            return .refused(.invalidCommand)
        }
        return session.submit(command)
    }
}
