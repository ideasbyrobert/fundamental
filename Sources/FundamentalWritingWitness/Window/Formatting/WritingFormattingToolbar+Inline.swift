import AppKit

extension WritingFormattingToolbar
{
    func configureTextStyles()
    {
        text.addItem(withTitle: "Text")
        (text.cell as? NSPopUpButtonCell)?.altersStateOfSelectedItem = false
        if let menu = text.menu
        {
            WritingInlineMenu.populate(menu)
        }
        text.autoenablesItems = false
        text.target = nil
        text.action = #selector(WritingWindowController.chooseTextStyle(_:))
        text.setAccessibilityIdentifier(Self.textID.rawValue)
        text.setAccessibilityLabel("Text style")
        text.toolTip = "Choose text styles for the selection or new typing"
        text.sizeToFit()
    }

    func updateTextStyles(_ projection: WritingProjection)
    {
        let selected = WritingInlineSelection(projection)
        text.isEnabled = selected != nil
        text.selectItem(at: 0)
        if let menu = text.menu
        {
            WritingInlineMenu.update(menu, selection: selected)
        }
        let active = WritingInlineChoice.all.compactMap
        {
            choice -> String? in
            switch selected?.state(of: choice.trait)
            {
            case .on: choice.title
            case .mixed: choice.title + ": mixed"
            case .off, nil: nil
            }
        }
        let description = active.isEmpty ? "Plain" : active.joined(
            separator: ", "
        )
        text.setAccessibilityHelp("Current text styles: " + description)
    }
}
