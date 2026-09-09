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
            WritingBlockStyleProposal(style: style, range: $1,
                                        in: $0)?.command
        }
    }

    @discardableResult
    func removeLists(in view: NSTextView) -> DocumentSessionTransition
    {
        changeFormatting(in: view)
        {
            .style($0.observation,
                   SemanticBlockStyleChange(removingListsIn: $1))
        }
    }

    private func changeFormatting(
        in view: NSTextView,
        change: (WritingProjection, DocumentRange) -> DocumentSessionCommand?
    ) -> DocumentSessionTransition
    {
        guard let range = formattingRange(in: view),
              let command = change(projection, range)
        else
        {
            project(in: view)
            return .refused(.invalidCommand)
        }
        return submitFormatting(command, in: view)
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
