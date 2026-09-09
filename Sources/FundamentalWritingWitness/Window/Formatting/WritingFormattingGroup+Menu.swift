import AppKit

@MainActor
extension WritingFormattingGroup
{
    func menuItem() -> NSMenuItem
    {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        let menu = NSMenu(title: title)
        for choice in choices
        {
            let command = NSMenuItem(
                title: choice.title, action: action, keyEquivalent: ""
            )
            command.representedObject = choice.style.rawValue
            menu.addItem(command)
        }
        item.submenu = menu
        return item
    }
}
