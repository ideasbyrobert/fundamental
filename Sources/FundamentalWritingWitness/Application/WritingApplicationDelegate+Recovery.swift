import AppKit

extension WritingApplicationDelegate
{
    func offerRecovery() async
    {
        guard let recoveryStore
        else
        {
            return
        }
        do
        {
            let catalog = try await recoveryStore.catalog()
            for record in catalog.recoverable
            {
                guard !controllers.contains(where:
                    { $0.fileOwner.recovery?.identifier == record.identifier })
                else
                {
                    continue
                }
                let decision = await WritingRecoveryPrompt.ask(
                    record, for: NSApp.keyWindow
                )
                switch decision
                {
                case .recover:
                    try openRecovery(record, store: recoveryStore)
                case .discard:
                    try await recoveryStore.discard(record.identifier)
                case .later:
                    break
                }
            }
            if !catalog.unreadable.isEmpty
            {
                await WritingRecoveryPrompt.failure(
                    "Some earlier checkpoints could not be read and were kept.",
                    for: NSApp.keyWindow
                )
            }
        }
        catch
        {
            await WritingRecoveryPrompt.failure(error.localizedDescription,
                                                   for: NSApp.keyWindow)
        }
    }

    func openRecovery(
        _ record: WritingRecoveryRecord, store: WritingRecoveryStore
    ) throws
    {
        let owner = WritingFileOwner.recover(record, store: store)
        guard let controller = WritingWindowController(owner: owner)
        else
        {
            throw WritingFileFailure.unavailableWindow
        }
        retain(controller)
        controller.documentWindow.center()
        controller.showWindow(nil)
    }
}
