import AppKit

extension WritingWindowController
{
    func updateDocumentState()
    {
        let location = fileOwner.binding?.location.url
        let unbound = fileOwner.displayName +
            (fileOwner.isRecovered ? " — Recovered" : "")
        let name = location?.lastPathComponent ?? unbound
        documentWindow.title = fileOwner.isSaving ? "\(name) — Saving" : name
        documentWindow.representedURL = location
        documentWindow.isDocumentEdited = fileOwner.session.isDirty
        formatting.update(bridge.projection)
        finder?.refresh()
        fileOwner.recovery?.observe(bridge.projection)
    }

    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool
    {
        if WritingApplicationMenu.findActions.contains(item.action)
        {
            return !choosingLocation && !hasFormattingSheet
        }
        if item.action == #selector(openLink(_:))
        {
            return validateOpenLink(item)
        }
        if item.action == #selector(chooseTextStyle(_:))
        {
            return validateTextStyle(item)
        }
        if item.action == #selector(chooseCodeLanguage(_:))
        {
            return canChooseCodeLanguage
        }
        if item.action == #selector(chooseTextScope(_:))
        {
            return validateTextScope(item)
        }
        if let group = WritingFormattingGroup.allCases.first(where:
            { $0.action == item.action })
        {
            return validateFormatting(item, group: group)
        }
        if item.action == #selector(saveDocument(_:)) ||
            item.action == #selector(saveDocumentAs(_:))
        {
            return !fileOwner.isSaving && !choosingLocation &&
                !hasFormattingSheet
        }
        return true
    }
}
