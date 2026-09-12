import AppKit

extension WritingWindowController
{
    func installRecovery(using store: WritingRecoveryStore)
    {
        if fileOwner.recovery == nil
        {
            fileOwner.recovery = WritingRecoveryCoordinator(
                owner: fileOwner, store: store
            )
        }
        fileOwner.recovery?.didFail =
        {
            [weak self] message in
            Task
            {
                guard let self, self.documentWindow.isVisible
                else
                {
                    return
                }
                await WritingRecoveryPrompt.failure(message,
                                                       for: self.documentWindow)
            }
        }
        fileOwner.recovery?.observe(bridge.projection)
    }

    func closeAfterRecovery(discard: Bool) -> Bool
    {
        guard let recovery = fileOwner.recovery
        else
        {
            if discard { discardApproved = true }
            return true
        }
        let observation = bridge.projection.observation
        closeTask = Task
        {
            defer { closeTask = nil }
            do
            {
                if discard
                {
                    try await recovery.discard()
                }
                else if recovery.sequence > 0,
                        let record = recovery.prepareSave()
                {
                    try await recovery.store.checkpoint(record)
                }
                guard bridge.finishComposition(in: textView),
                      bridge.projection.observation == observation
                else
                {
                    if discard
                    {
                        fileOwner.recovery = nil
                        installRecovery(using: recovery.store)
                    }
                    return false
                }
                discardApproved = true
                documentWindow.performClose(nil)
                return true
            }
            catch
            {
                await WritingRecoveryPrompt.failure(error.localizedDescription,
                                                       for: documentWindow)
                return false
            }
        }
        return false
    }
}
