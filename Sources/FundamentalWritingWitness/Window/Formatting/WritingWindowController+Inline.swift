import AppKit

extension WritingWindowController
{
    var inlineSelection: WritingInlineSelection?
    {
        WritingInlineSelection(bridge.composition?.presentation ??
            bridge.projection)
    }

    var canChooseTextStyle: Bool
    {
        canFormatSelection && inlineSelection != nil
    }

    @objc func chooseTextStyle(_ sender: Any?)
    {
        guard canChooseTextStyle,
              let choice = WritingInlineChoice.selected(from: sender)
        else
        {
            return
        }
        bridge.toggleInline(choice.trait, in: textView)
    }

    func validateTextStyle(_ item: NSValidatedUserInterfaceItem) -> Bool
    {
        guard let item = item as? NSMenuItem
        else
        {
            return canChooseTextStyle
        }
        item.state = .off
        guard canChooseTextStyle,
              let choice = WritingInlineChoice.selected(from: item),
              let selected = inlineSelection
        else
        {
            return false
        }
        item.state = WritingInlineMenu.value(selected.state(of: choice.trait))
        return true
    }
}
