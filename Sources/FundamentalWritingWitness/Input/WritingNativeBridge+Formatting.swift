import AppKit
import FundamentalDocument

extension WritingNativeBridge
{
    @discardableResult
    func changeStyle(
        _ style: CanonicalBlockStyle, in view: NSTextView
    ) -> DocumentSessionTransition
    {
        changeFormatting(in: view)
        {
            SemanticBlockStyleChange(range: $0, style: style)
        }
    }

    @discardableResult
    func removeLists(in view: NSTextView) -> DocumentSessionTransition
    {
        changeFormatting(in: view)
        {
            SemanticBlockStyleChange(removingListsIn: $0)
        }
    }

    private func changeFormatting(
        in view: NSTextView,
        change: (DocumentRange) -> SemanticBlockStyleChange
    ) -> DocumentSessionTransition
    {
        guard view.textLayoutManager != nil, finishComposition(in: view),
              view.string.utf16.elementsEqual(projection.text.utf16),
              let range = projection.range(view.selectedRange())
        else
        {
            project(in: view)
            return .refused(.invalidCommand)
        }
        let result = session.submit(.style(
            projection.observation, change(range)
        ))
        project(in: view)
        view.window?.makeFirstResponder(view)
        return result
    }

    func updateTyping(in view: NSTextView)
    {
        let blocks = projection.snapshot.snapshot.document.content.blocks
        guard let index = projection.map.spans.lastIndex(where:
            { $0.range.location <= projection.selection.location })
        else
        {
            return
        }
        var ordinal = blocks[..<index].reversed().prefix
        {
            if case let .listItem(item) = $0.block
            {
                return item.kind == .numbered
            }
            return false
        }.count
        if let attributes = WritingTypography.attributes(
            for: blocks[index].block, ordinal: &ordinal
        ), !NSDictionary(dictionary: attributes)
            .isEqual(to: view.typingAttributes)
        {
            view.typingAttributes = attributes
        }
    }
}
