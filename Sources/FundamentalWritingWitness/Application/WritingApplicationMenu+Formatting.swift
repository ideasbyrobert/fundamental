import AppKit

extension WritingApplicationMenu
{
    static func formatMenu() -> NSMenu
    {
        let menu = NSMenu(title: "Format")
        for group in WritingFormattingGroup.allCases
        {
            menu.addItem(group.menuItem())
        }
        return menu
    }
}
