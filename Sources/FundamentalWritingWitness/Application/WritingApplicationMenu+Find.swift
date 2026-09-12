import AppKit

extension WritingApplicationMenu
{
    static var findActions: [Selector?]
    {
        [#selector(WritingWindowController.findText(_:)),
         #selector(WritingWindowController.findAndReplace(_:)),
         #selector(WritingWindowController.findNext(_:)),
         #selector(WritingWindowController.findPrevious(_:))]
    }

    static func addFind(to menu: NSMenu)
    {
        menu.addItem(.separator())
        let entries: [(String, String, NSEvent.ModifierFlags)] = [
            ("Find…", "f", [.command]),
            ("Find and Replace…", "f", [.command, .option]),
            ("Find Next", "g", [.command]),
            ("Find Previous", "g", [.command, .shift])
        ]
        for (entry, action) in zip(entries, findActions)
        {
            let item = NSMenuItem(title: entry.0, action: action,
                                  keyEquivalent: entry.1)
            item.keyEquivalentModifierMask = entry.2
            menu.addItem(item)
        }
    }
}
