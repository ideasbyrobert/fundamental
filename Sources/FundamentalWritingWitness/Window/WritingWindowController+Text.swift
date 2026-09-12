import AppKit

extension WritingWindowController
{
    @objc func exportText(_ sender: Any?)
    {
        Task { await performTextExport() }
    }

    func performTextExport() async
    {
        guard !fileOwner.isSaving, !choosingLocation, !hasFormattingSheet,
              closeTask == nil, bridge.finishComposition(in: textView)
        else
        {
            return
        }
        choosingLocation = true
        defer { choosingLocation = false }
        let name = fileOwner.binding?.location.url.lastPathComponent ??
            fileOwner.displayName
        guard let location = await WritingTextPanels.save(
            for: documentWindow, name: name
        ), bridge.finishComposition(in: textView)
        else
        {
            return
        }
        do
        {
            try await fileOwner.exportText(to: location)
        }
        catch
        {
            await WritingFileErrorPrompt.show(error, for: documentWindow)
        }
    }
}
