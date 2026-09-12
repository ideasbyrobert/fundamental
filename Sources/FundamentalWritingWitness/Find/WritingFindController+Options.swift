import AppKit

extension WritingFindController
{
    func configureOptions()
    {
        let menu = NSMenu(title: "Find Options")
        menu.delegate = self
        let matching = NSMenuItem(title: "Match Case",
                                 action: #selector(toggleCase(_:)),
                                 keyEquivalent: "")
        let replacement = NSMenuItem(title: "Show Replace",
                                    action: #selector(toggleReplace(_:)),
                                    keyEquivalent: "")
        for item in [matching, replacement]
        {
            item.target = self
            menu.addItem(item)
        }
        bar.query.searchMenuTemplate = menu
    }

    func menuNeedsUpdate(_ menu: NSMenu)
    {
        for item in menu.items
        {
            if item.action == #selector(toggleCase(_:))
            {
                item.state = caseSensitive ? .on : .off
            }
            if item.action == #selector(toggleReplace(_:))
            {
                item.state = bar.replacementRow.isHidden ? .off : .on
            }
        }
    }

    @objc func toggleCase(_ sender: Any?)
    {
        caseSensitive.toggle()
        refresh()
    }

    @objc func toggleReplace(_ sender: Any?)
    {
        bar.replacementRow.isHidden.toggle()
        layout()
        refresh()
    }
}
