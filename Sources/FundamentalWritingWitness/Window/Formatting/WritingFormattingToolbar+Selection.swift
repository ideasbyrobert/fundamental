import AppKit

extension WritingFormattingToolbar
{
    func update(_ projection: WritingProjection)
    {
        block.isEnabled = projection.canFormatBlocks
        list.isEnabled = projection.canFormatBlocks
        if let menu = block.menu
        {
            WritingCodeLanguageMenu.update(menu,
                available: WritingCodeLanguageRequest(in: projection) != nil)
        }
        select(WritingFormattingGroup.paragraph.selectionTitles(in: projection),
               in: block)
        select(WritingFormattingGroup.list.selectionTitles(in: projection),
               in: list)
        for item in list.itemArray.dropFirst()
        {
            item.state = item === list.selectedItem ? .on : .off
            item.isHidden = item.title == "Mixed" && item.state == .off
        }
        let current = list.selectedItem?.title ?? "Mixed"
        list.setAccessibilityHelp("Current list style: \(current)")
    }

    private func select(
        _ titles: [String], in popup: NSPopUpButton
    )
    {
        popup.lastItem?.title = "Mixed"
        let title = titles.first.flatMap
        {
            first in titles.allSatisfy { $0 == first } ? first : nil
        } ?? "Mixed"
        if let item = popup.itemArray.first(where:
            { $0.title == title && $0.representedObject != nil })
        {
            popup.select(item)
            popup.lastItem?.isHidden = true
        }
        else
        {
            popup.lastItem?.title = title
            popup.lastItem?.isHidden = false
            popup.select(popup.lastItem)
        }
    }
}
