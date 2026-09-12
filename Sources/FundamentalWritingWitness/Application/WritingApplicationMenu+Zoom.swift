import AppKit

extension WritingApplicationMenu
{
    static let zoomActions: Set<Selector> = [
        #selector(WritingWindowController.zoomIn(_:)),
        #selector(WritingWindowController.zoomOut(_:)),
        #selector(WritingWindowController.actualSize(_:))
    ]

    static func viewMenu() -> NSMenu
    {
        let menu = NSMenu(title: "View")
        for (title, action, key) in [
            ("Zoom In", #selector(WritingWindowController.zoomIn(_:)), "+"),
            ("Zoom Out", #selector(WritingWindowController.zoomOut(_:)), "-"),
            ("Actual Size", #selector(WritingWindowController.actualSize(_:)),
             "0")
        ]
        {
            let item = NSMenuItem(title: title, action: action,
                                 keyEquivalent: key)
            item.keyEquivalentModifierMask = [.command]
            menu.addItem(item)
        }
        let alias = NSMenuItem(title: "Increase Writing Zoom",
            action: #selector(WritingWindowController.zoomIn(_:)),
            keyEquivalent: "=")
        alias.keyEquivalentModifierMask = [.command]
        alias.isHidden = true
        alias.allowsKeyEquivalentWhenHidden = true
        menu.addItem(alias)
        return menu
    }
}
