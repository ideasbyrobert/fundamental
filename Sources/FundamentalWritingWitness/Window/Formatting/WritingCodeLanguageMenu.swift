import AppKit

@MainActor
enum WritingCodeLanguageMenu
{
    static let title = "Code Language…"
    static let identifier = NSUserInterfaceItemIdentifier(
        "FundamentalCodeLanguage"
    )
    static let separatorID = NSUserInterfaceItemIdentifier(
        "FundamentalCodeLanguageSeparator"
    )

    static func items() -> [NSMenuItem]
    {
        let separator = NSMenuItem.separator()
        separator.identifier = separatorID
        let item = NSMenuItem(title: title,
            action: #selector(WritingWindowController.chooseCodeLanguage(_:)),
            keyEquivalent: "")
        item.identifier = identifier
        return [separator, item]
    }

    static func isChoice(_ sender: Any?) -> Bool
    {
        let item = (sender as? NSPopUpButton)?.selectedItem
            ?? sender as? NSMenuItem
        return item?.identifier == identifier
    }

    static func update(_ menu: NSMenu, available: Bool)
    {
        for item in menu.items where item.identifier == identifier ||
            item.identifier == separatorID
        {
            item.isHidden = !available
            item.isEnabled = available
        }
    }
}
