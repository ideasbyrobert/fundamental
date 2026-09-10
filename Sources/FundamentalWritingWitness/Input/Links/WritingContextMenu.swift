import AppKit

@MainActor
enum WritingContextMenu
{
    static func make(in projection: WritingProjection) -> NSMenu
    {
        let menu = WritingApplicationMenu.editMenu()
        menu.title = ""
        if let request = WritingLinkRequest(in: projection)
        {
            menu.insertItem(WritingOpenLinkMenu.item(request), at: 0)
            menu.insertItem(.separator(), at: 1)
        }
        let format = NSMenuItem(title: "Format", action: nil, keyEquivalent: "")
        format.submenu = WritingApplicationMenu.formatMenu()
        menu.addItem(.separator())
        menu.addItem(format)
        return menu
    }
}
