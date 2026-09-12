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
        guard let appearance = WritingTypingAppearance(projection, zoom: zoom)
        else
        {
            return
        }
        let attributes = appearance.attributes
        if !NSDictionary(dictionary: attributes)
            .isEqual(to: view.typingAttributes)
        {
            view.typingAttributes = attributes
        }
    }
}
