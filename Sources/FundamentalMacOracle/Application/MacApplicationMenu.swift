import AppKit

@MainActor
enum MacApplicationMenu
{
    static func install(in application: NSApplication)
    {
        let main = NSMenu()
        let applicationItem = NSMenuItem()
        main.addItem(applicationItem)
        applicationItem.submenu = applicationMenu()
        let editItem = NSMenuItem()
        main.addItem(editItem)
        editItem.submenu = editMenu()
        application.mainMenu = main
    }

    private static func applicationMenu() -> NSMenu
    {
        let menu = NSMenu(title: "Fundamental")
        let quit = NSMenuItem(
            title: "Quit Fundamental",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quit)
        return menu
    }

    private static func editMenu() -> NSMenu
    {
        let menu = NSMenu(title: "Edit")
        let copy = NSMenuItem(
            title: "Copy",
            action: #selector(NSText.copy(_:)),
            keyEquivalent: "c"
        )
        menu.addItem(copy)
        return menu
    }
}
