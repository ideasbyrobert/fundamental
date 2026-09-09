import AppKit
import FundamentalDocument

extension WritingFormattingToolbar
{
    func configureControls()
    {
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
        block.setAccessibilityIdentifier(Self.blockID.rawValue)
        list.setAccessibilityIdentifier(Self.listID.rawValue)
        block.toolTip = "Choose the meaning of the selected paragraphs"
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
