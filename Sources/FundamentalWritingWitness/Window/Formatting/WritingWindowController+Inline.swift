import AppKit

extension WritingWindowController
{
    var textSelection: WritingSelectedAttributes?
    {
        WritingSelectedAttributes(bridge.composition?.presentation ??
            bridge.projection)
    }

    var inlineSelection: WritingInlineSelection?
    {
        textSelection.map { WritingInlineSelection($0) }
    }

    var canChooseTextStyle: Bool
    {
        canFormatSelection && inlineSelection != nil
    }

    @objc func chooseTextStyle(_ sender: Any?)
    {
        if WritingOpenLinkMenu.choice(from: sender) != nil
        {
            openLink(sender)
            return
        }
        if WritingScopeMenu.kind(from: sender) != nil
        {
            chooseTextScope(sender)
            return
        }
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
