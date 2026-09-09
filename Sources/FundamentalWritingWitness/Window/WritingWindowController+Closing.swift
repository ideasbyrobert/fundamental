import AppKit

extension WritingWindowController
{
    func windowShouldClose(_ sender: NSWindow) -> Bool
    {
        sender === documentWindow && mayClose()
    }

    func windowWillClose(_ notification: Notification)
    {
        discardApproved = true
        didClose?()
    }

    func mayClose() -> Bool
    {
        if discardApproved
        {
            return true
        }
        guard !fileOwner.isSaving, !choosingLocation, closeTask == nil,
              codeLanguageSheet == nil,
              bridge.finishComposition(in: textView)
        else
        {
            return false
        }
        guard let current = WritingProjection(fileOwner.session.state)
        else
        {
            return false
        }
        if !fileOwner.session.isDirty ||
            (fileOwner.binding == nil && current.text.isEmpty)
        {
            return true
        }
        switch confirmDiscard()
        {
        case .discard:
            discardApproved = true
            return true
        case .cancel:
            return false
        case .save:
            closeTask = Task
            {
                let result = await performSave(
                    choosingLocation: false, closing: true
                )
                closeTask = nil
                return result
            }
            return false
        }
    }
}
