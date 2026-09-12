import AppKit

extension WritingWindowController
{
    func windowShouldClose(_ sender: NSWindow) -> Bool
    {
        sender === documentWindow && mayClose()
    }

    func windowWillClose(_ notification: Notification)
    {
        fileOwner.recovery?.stop()
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
              !hasFormattingSheet,
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
        let pristine = fileOwner.binding == nil && current.text.isEmpty &&
            !fileOwner.session.canUndo && !fileOwner.session.canRedo &&
            (fileOwner.recovery?.sequence ?? 0) == 0
        if !fileOwner.session.isDirty || pristine
        {
            return closeAfterRecovery(discard: false)
        }
        switch confirmDiscard()
        {
        case .discard:
            return closeAfterRecovery(discard: true)
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
