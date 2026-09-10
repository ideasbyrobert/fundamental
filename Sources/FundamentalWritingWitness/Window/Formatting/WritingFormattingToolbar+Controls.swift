import AppKit
import FundamentalDocument

extension WritingFormattingToolbar
{
    func configureControls()
    {
        configureTextStyles()
        for (title, style) in WritingFormattingGroup.paragraph.choices
        {
            block.addItem(withTitle: title)
            block.lastItem?.representedObject = style.rawValue
        }
        list.addItem(withTitle: "List")
        (list.cell as? NSPopUpButtonCell)?.altersStateOfSelectedItem = false
        for (title, style) in WritingFormattingGroup.list.choices
        {
            list.addItem(withTitle: title)
            list.lastItem?.representedObject = style.rawValue
        }
        configure(block, label: "Block style", group: .paragraph)
        configure(list, label: "List", group: .list)
        block.widthAnchor.constraint(equalToConstant: block.frame.width)
            .isActive = true
        if let menu = block.menu
        {
            let insertion = menu.items.count - 1
            for (offset, item) in WritingCodeLanguageMenu.items().enumerated()
            {
                menu.insertItem(item, at: insertion + offset)
            }
        }
        block.setAccessibilityIdentifier(Self.blockID.rawValue)
        list.setAccessibilityIdentifier(Self.listID.rawValue)
        block.toolTip = "Choose the meaning of the selected text"
        list.toolTip = "Choose a list style for the selected paragraphs"
    }

    private func configure(
        _ popup: NSPopUpButton, label: String, group: WritingFormattingGroup
    )
    {
        popup.autoenablesItems = false
        popup.addItem(withTitle: "Mixed")
        popup.lastItem?.isEnabled = false
        popup.target = nil
        popup.action = group.action
        popup.setAccessibilityLabel(label)
        popup.sizeToFit()
    }
}
