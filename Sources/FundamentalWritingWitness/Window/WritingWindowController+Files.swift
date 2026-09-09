import AppKit
import FundamentalStorage

extension WritingWindowController
{
    @objc func saveDocument(_ sender: Any?)
    {
        Task
        {
            await performSave(choosingLocation: false, closing: false)
        }
    }

    @objc func saveDocumentAs(_ sender: Any?)
    {
        Task
        {
            await performSave(choosingLocation: true, closing: false)
        }
    }

    @discardableResult
    func performSave(choosingLocation choose: Bool, closing: Bool) async -> Bool
    {
        guard !fileOwner.isSaving, !choosingLocation, codeLanguageSheet == nil,
              bridge.finishComposition(in: textView)
        else
        {
            return false
        }
        do
        {
            let location: DocumentFileLocation
            if !choose, let binding = fileOwner.binding
            {
                location = binding.location
            }
            else
            {
                choosingLocation = true
                let selected = await WritingFilePanels.save(
                    for: documentWindow,
                    name: fileOwner.binding?.location.url.lastPathComponent
                )
                choosingLocation = false
                guard let selected
                else
                {
                    return false
                }
                location = selected
            }
            guard bridge.finishComposition(in: textView)
            else
            {
                return false
            }
            try await fileOwner.save(to: location)
            if !fileOwner.retainedItems.isEmpty
            {
                await WritingFileErrorPrompt.showRetained(
                    fileOwner.retainedItems, for: documentWindow
                )
            }
            if closing
            {
                guard bridge.finishComposition(in: textView),
                      !fileOwner.session.isDirty,
                      !fileOwner.session.hasPendingSave
                else
                {
                    return false
                }
                discardApproved = true
                documentWindow.performClose(nil)
            }
            return true
        }
        catch
        {
            await WritingFileErrorPrompt.show(error, for: documentWindow)
            return false
        }
    }
}
