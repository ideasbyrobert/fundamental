import AppKit

extension WritingApplicationDelegate
{
    @objc func importText(_ sender: Any?)
    {
        guard !choosingTextImport
        else
        {
            return
        }
        choosingTextImport = true
        Task
        {
            defer { choosingTextImport = false }
            let window = NSApp.keyWindow
            guard let location = await WritingTextPanels.open(for: window)
            else
            {
                return
            }
            do
            {
                try await openText(location)
            }
            catch
            {
                await WritingFileErrorPrompt.show(error, for: window)
            }
        }
    }

    func openText(_ location: URL) async throws
    {
        let owner = try await WritingFileOwner.importText(location)
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
