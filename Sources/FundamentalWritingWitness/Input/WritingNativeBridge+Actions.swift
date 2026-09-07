import AppKit
import FundamentalDocument

extension WritingNativeBridge
{
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
        guard finishComposition(in: view), project(in: view),
              projection.selection.length > 0
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
