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
        if let style = prose.first, prose.allSatisfy({ $0 == style }),
           let item = block.itemArray.first(where:
               { $0.representedObject as? String == style.rawValue })
        {
            block.select(item)
        }
        else
        {
            block.selectItem(withTitle: "Mixed")
        }
        bulleted.state = state(.bulleted, in: styles)
        numbered.state = state(.numbered, in: styles)
    }

    private func state(
        _ style: CanonicalBlockStyle, in styles: [CanonicalBlockStyle]
    ) -> NSControl.StateValue
    {
        if styles.allSatisfy({ $0 == style })
        {
            return .on
        }
        return styles.contains(style) ? .mixed : .off
    }
}
