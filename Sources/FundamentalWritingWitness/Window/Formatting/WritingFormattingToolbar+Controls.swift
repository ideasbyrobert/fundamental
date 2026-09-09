import AppKit
import FundamentalDocument

extension WritingFormattingToolbar
{
    func configureControls()
    {
        for (title, style) in [("Body", CanonicalBlockStyle.body),
                               ("Title", .title), ("Heading", .heading),
                               ("Subheading", .subheading)]
        {
            block.addItem(withTitle: title)
            block.lastItem?.representedObject = style.rawValue
        }
        list.addItem(withTitle: "List")
        (list.cell as? NSPopUpButtonCell)?.altersStateOfSelectedItem = false
        for (title, style) in [("No List", CanonicalBlockStyle.body),
                               ("Bulleted", .bulleted),
                               ("Numbered", .numbered)]
        {
            list.addItem(withTitle: title)
            list.lastItem?.representedObject = style.rawValue
        }
        configure(block, label: "Block style", action: #selector(chooseBlock))
        configure(list, label: "List", action: #selector(chooseList))
        block.setAccessibilityIdentifier(Self.blockID.rawValue)
        list.setAccessibilityIdentifier(Self.listID.rawValue)
        block.toolTip = "Choose the meaning of the selected paragraphs"
        list.toolTip = "Choose a list style for the selected paragraphs"
    }

    private func configure(
        _ popup: NSPopUpButton, label: String, action: Selector
    )
    {
        popup.autoenablesItems = false
        popup.addItem(withTitle: "Mixed")
        popup.lastItem?.isEnabled = false
        popup.target = self
        popup.action = action
        popup.setAccessibilityLabel(label)
        popup.sizeToFit()
    }
}
