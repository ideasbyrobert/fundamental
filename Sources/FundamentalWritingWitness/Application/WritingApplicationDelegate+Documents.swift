import AppKit
import FundamentalDocument
import FundamentalStorage

extension WritingApplicationDelegate
{
    @objc func newDocument(_ sender: Any?)
    {
        guard let seed = WritingDocumentSeed(),
              let controller = WritingWindowController(
                  session: DocumentSession(state: seed.state)
              )
        else
        {
            return
        }
        retain(controller)
        controller.documentWindow.center()
        controller.showWindow(sender)
    }

    @objc func openDocument(_ sender: Any?)
    {
        Task
        {
            if let location = await WritingFilePanels.open(for: NSApp.keyWindow)
            {
                await open(location)
            }
        }
    }

    func application(_ application: NSApplication, open urls: [URL])
    {
        Task
        {
            for url in urls
            {
                if let location = DocumentFileLocation(url)
                {
                    await open(location)
                }
            }
        }
    }

    func open(_ location: DocumentFileLocation) async
    {
        if let existing = controllers.first(where:
            { $0.fileOwner.binding?.location == location })
        {
            existing.showWindow(nil)
            return
        }
        do
        {
            let owner = try await WritingFileOwner.open(location)
            guard let controller = WritingWindowController(owner: owner)
            else
            {
                throw WritingFileFailure.unavailableWindow
            }
            retain(controller)
            controller.documentWindow.center()
            controller.showWindow(nil)
        }
        catch
        {
            await WritingFileErrorPrompt.show(error, for: NSApp.keyWindow)
        }
    }
}
