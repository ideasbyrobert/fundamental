import AppKit
import FundamentalDocument

extension WritingFormattingToolbar
{
    func update(_ projection: WritingProjection)
    {
        guard let selected = SemanticBlockSelection(
            range: projection.snapshot.selection.range,
            in: projection.snapshot.snapshot.document
        )
        else
        {
            return
        }
        let styles = selected.blocks.compactMap
        {
            CanonicalBlockStyle($0.block)
        }
        let prose = styles.map
        {
            [.bulleted, .numbered].contains($0) ? CanonicalBlockStyle.body : $0
        }
        let lists = styles.map
        {
            [.bulleted, .numbered].contains($0) ? $0 : CanonicalBlockStyle.body
        }
        select(prose, in: block)
        select(lists, in: list)
        for item in list.itemArray.dropFirst()
        {
            item.state = item === list.selectedItem ? .on : .off
            item.isHidden = item.title == "Mixed" && item.state == .off
        }
        let current = list.selectedItem?.title ?? "Mixed"
        list.setAccessibilityHelp("Current list style: \(current)")
    }

    private func select(
        _ styles: [CanonicalBlockStyle], in popup: NSPopUpButton
    )
    {
        if let style = styles.first, styles.allSatisfy({ $0 == style }),
           let item = popup.itemArray.first(where:
               { $0.representedObject as? String == style.rawValue })
        {
            popup.select(item)
        }
        else
        {
            popup.selectItem(withTitle: "Mixed")
        }
    }
}
