import AppKit

@MainActor
struct WritingApplicationMenu
{
    static func install(in application: NSApplication)
    {
        let main = NSMenu()
        let app = NSMenuItem(title: "Fundamental Writing Witness",
                             action: nil, keyEquivalent: "")
        app.submenu = NSMenu(title: "Fundamental Writing Witness")
        app.submenu?.addItem(NSMenuItem(
            title: "Quit Fundamental Writing Witness",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
        main.addItem(app)
        let file = NSMenuItem(title: "File", action: nil, keyEquivalent: "")
        file.submenu = NSMenu(title: "File")
        file.submenu?.addItem(NSMenuItem(
            title: "Close",
            action: #selector(NSWindow.performClose(_:)),
            keyEquivalent: "w"
        ))
        main.addItem(file)
        let edit = NSMenuItem(title: "Edit", action: nil, keyEquivalent: "")
        edit.submenu = editMenu()
        main.addItem(edit)
        application.mainMenu = main
    }

    private static func editMenu() -> NSMenu
    {
        let menu = NSMenu(title: "Edit")
        menu.addItem(NSMenuItem(
            title: "Undo",
            action: #selector(WritingTextView.undoCanonicalEdit(_:)),
            keyEquivalent: "z"
        ))
        let redo = NSMenuItem(
            title: "Redo",
            action: #selector(WritingTextView.redoCanonicalEdit(_:)),
            keyEquivalent: "z"
        )
        redo.keyEquivalentModifierMask = [.command, .shift]
        menu.addItem(redo)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Copy",
                                action: #selector(NSText.copy(_:)),
                                keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Paste",
                                action: #selector(NSText.paste(_:)),
                                keyEquivalent: "v"))
        menu.addItem(NSMenuItem(title: "Select All",
                                action: #selector(NSText.selectAll(_:)),
                                keyEquivalent: "a"))
        return menu
    }
}
