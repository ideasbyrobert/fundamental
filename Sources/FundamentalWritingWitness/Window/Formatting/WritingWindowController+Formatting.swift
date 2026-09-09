import AppKit

extension WritingWindowController
{
    var canFormatSelection: Bool
    {
        let responder = documentWindow.firstResponder
        return documentWindow.isKeyWindow &&
            documentWindow.attachedSheet == nil && !choosingLocation &&
            !fileOwner.isSaving && closeTask == nil && textView.isEditable &&
            (responder === textView || responder === formatting.block ||
                responder === formatting.list)
    }

    @objc func chooseParagraphStyle(_ sender: Any?)
    {
        applyFormatting(.paragraph, sender: sender)
    }

    @objc func chooseListStyle(_ sender: Any?)
    {
        applyFormatting(.list, sender: sender)
    }

    private func applyFormatting(
        _ group: WritingFormattingGroup, sender: Any?
    )
    {
        guard canFormatSelection, let style = group.style(from: sender)
        else
        {
            return
        }
        if group == .list && style == .body
        {
            bridge.removeLists(in: textView)
        }
        else
        {
            bridge.changeStyle(style, in: textView)
        }
    }

    func validateFormatting(
        _ item: any NSValidatedUserInterfaceItem,
        group: WritingFormattingGroup
    ) -> Bool
    {
        guard let menu = item as? NSMenuItem
        else
        {
            return canFormatSelection
        }
        menu.state = .off
        guard canFormatSelection, let style = group.style(from: menu),
              let title = group.choices.first(where:
                { $0.style == style })?.title
        else
        {
            return false
        }
        let titles = group.selectionTitles(in: bridge.projection)
        let count = titles.filter { $0 == title }.count
        menu.state = count == 0 ? .off : count == titles.count ? .on : .mixed
        return true
    }
}
