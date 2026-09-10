import AppKit

@MainActor
enum WritingScopeMenu
{
    static func populate(_ menu: NSMenu)
    {
        menu.addItem(.separator())
        for kind in WritingScopeKind.allCases
        {
            let item = NSMenuItem(title: kind.title + "…",
                action: #selector(WritingWindowController.chooseTextScope(_:)),
                keyEquivalent: kind == .link ? "k" : "")
            item.identifier = NSUserInterfaceItemIdentifier(kind.rawValue)
            item.keyEquivalentModifierMask = [.command]
            menu.addItem(item)
            if kind == .link
            {
                menu.addItem(WritingOpenLinkMenu.item())
            }
        }
    }

    static func kind(from sender: Any?) -> WritingScopeKind?
    {
        let item = (sender as? NSPopUpButton)?.selectedItem
            ?? sender as? NSMenuItem
        return item?.identifier.flatMap
        {
            WritingScopeKind(rawValue: $0.rawValue)
        }
    }

    static func update(_ menu: NSMenu, selection: WritingSelectedAttributes?)
    {
        for item in menu.items
        {
            guard let kind = kind(from: item)
            else
            {
                continue
            }
            item.isEnabled = selection != nil
            let state = selection.map
            {
                WritingScopeSelection(kind: kind, in: $0).state
            } ?? .off
            item.state = WritingInlineMenu.value(state)
        }
    }
}
