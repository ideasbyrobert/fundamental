import AppKit

@MainActor
enum WritingOpenLinkMenu
{
    static let identifier = NSUserInterfaceItemIdentifier("FundamentalOpenLink")

    static func item(_ request: WritingLinkRequest? = nil) -> NSMenuItem
    {
        let item = NSMenuItem(title: "Open Link",
            action: #selector(WritingWindowController.openLink(_:)),
            keyEquivalent: "")
        item.identifier = identifier
        item.representedObject = request
        item.isEnabled = request != nil
        return item
    }

    static func choice(from sender: Any?) -> NSMenuItem?
    {
        let item = (sender as? NSPopUpButton)?.selectedItem ??
            sender as? NSMenuItem
        return item?.identifier == identifier ? item : nil
    }

    static func update(_ menu: NSMenu, request: WritingLinkRequest?)
    {
        guard let item = menu.items.first(where:
            { $0.identifier == identifier })
        else
        {
            return
        }
        item.representedObject = request
        item.isEnabled = request != nil
    }
}
