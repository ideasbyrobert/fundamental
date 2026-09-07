import AppKit

extension WritingWindowController
{
    func updateDocumentState()
    {
        let location = fileOwner.binding?.location.url
        let name = location?.lastPathComponent ?? "Untitled"
        documentWindow.title = fileOwner.isSaving ? "\(name) — Saving" : name
        documentWindow.representedURL = location
        documentWindow.isDocumentEdited = fileOwner.session.isDirty
        formatting.update(bridge.projection)
    }

    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool
    {
        if item.action == #selector(saveDocument(_:)) ||
            item.action == #selector(saveDocumentAs(_:))
        {
            return !fileOwner.isSaving && !choosingLocation
        }
        return true
    }
}
