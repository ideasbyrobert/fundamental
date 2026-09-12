import AppKit

@MainActor
struct WritingApplicationMenu
{
    static func install(in application: NSApplication)
    {
        application.mainMenu = make()
    }

    static func make() -> NSMenu
    {
        let main = NSMenu()
        let app = NSMenuItem(title: "Fundamental",
                             action: nil, keyEquivalent: "")
        app.submenu = NSMenu(title: "Fundamental")
        app.submenu?.addItem(NSMenuItem(
            title: "Quit Fundamental",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
        main.addItem(app)
        let file = NSMenuItem(title: "File", action: nil, keyEquivalent: "")
        file.submenu = fileMenu()
        main.addItem(file)
        let edit = NSMenuItem(title: "Edit", action: nil, keyEquivalent: "")
        edit.submenu = editMenu()
        main.addItem(edit)
        let format = NSMenuItem(title: "Format", action: nil, keyEquivalent: "")
        format.submenu = formatMenu()
        main.addItem(format)
        return main
    }

    static func editMenu() -> NSMenu
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
            keyEquivalent: "Z"
        )
        redo.keyEquivalentModifierMask = [.command]
        menu.addItem(redo)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Cut",
                                action: #selector(NSText.cut(_:)),
                                keyEquivalent: "x"))
        menu.addItem(NSMenuItem(title: "Copy",
                                action: #selector(NSText.copy(_:)),
                                keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Paste",
                                action: #selector(NSText.paste(_:)),
                                keyEquivalent: "v"))
        menu.addItem(NSMenuItem(title: "Select All",
                                action: #selector(NSText.selectAll(_:)),
                                keyEquivalent: "a"))
        addFind(to: menu)
        return menu
    }
}
