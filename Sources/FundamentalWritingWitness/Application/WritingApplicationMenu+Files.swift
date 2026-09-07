import AppKit

extension WritingApplicationMenu
{
    static func fileMenu() -> NSMenu
    {
        let menu = NSMenu(title: "File")
        menu.addItem(NSMenuItem(
            title: "New",
            action: #selector(WritingApplicationDelegate.newDocument(_:)),
            keyEquivalent: "n"
        ))
        menu.addItem(NSMenuItem(
            title: "Open…",
            action: #selector(WritingApplicationDelegate.openDocument(_:)),
            keyEquivalent: "o"
        ))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "Save",
            action: #selector(WritingWindowController.saveDocument(_:)),
            keyEquivalent: "s"
        ))
        let saveAs = NSMenuItem(
            title: "Save As…",
            action: #selector(WritingWindowController.saveDocumentAs(_:)),
            keyEquivalent: "S"
        )
        saveAs.keyEquivalentModifierMask = [.command]
        menu.addItem(saveAs)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "Close",
            action: #selector(NSWindow.performClose(_:)),
            keyEquivalent: "w"
        ))
        return menu
    }
}
