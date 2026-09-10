import AppKit

@MainActor
final class WritingInlineMenu: NSObject, NSMenuDelegate
{
    static let shared = WritingInlineMenu()

    static func menuItem() -> NSMenuItem
    {
        let item = NSMenuItem(title: "Text Style", action: nil,
                              keyEquivalent: "")
        let menu = NSMenu(title: item.title)
        populate(menu)
        item.submenu = menu
        return item
    }

    static func populate(_ menu: NSMenu)
    {
        for choice in WritingInlineChoice.all
        {
            if choice.trait == .superscript
            {
                menu.addItem(.separator())
            }
            menu.addItem(choice.menuItem())
        }
        menu.delegate = shared
    }

    static func update(_ menu: NSMenu, selection: WritingInlineSelection?)
    {
        for item in menu.items
        {
            guard let choice = WritingInlineChoice.selected(from: item)
            else
            {
                continue
            }
            item.isEnabled = selection != nil
            item.state = value(selection?.state(of: choice.trait) ?? .off)
        }
    }

    static func value(_ state: WritingInlineState) -> NSControl.StateValue
    {
        switch state
        {
        case .off: .off
        case .on: .on
        case .mixed: .mixed
        }
    }

    func menuNeedsUpdate(_ menu: NSMenu)
    {
        let action = #selector(WritingWindowController.chooseTextStyle(_:))
        let controller = NSApp.target(forAction: action, to: nil, from: menu)
            as? WritingWindowController
        let selected = controller?.canChooseTextStyle == true
            ? controller?.inlineSelection : nil
        Self.update(menu, selection: selected)
    }
}
