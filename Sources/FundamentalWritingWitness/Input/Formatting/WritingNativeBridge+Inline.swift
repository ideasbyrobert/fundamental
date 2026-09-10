import AppKit
import FundamentalDocument

extension WritingNativeBridge
{
    @discardableResult
    func toggleInline(
        _ trait: SemanticInlineTrait, in view: NSTextView
    ) -> DocumentSessionTransition
    {
        guard let range = formattingRange(in: view),
              view.selectedRange() == projection.selection,
              let selected = WritingInlineSelection(projection)
        else
        {
            project(in: view)
            return .refused(.invalidCommand)
        }
        let enabled = selected.state(of: trait) != .on
        let command: DocumentSessionCommand
        if range.start == range.end
        {
            command = .typing(projection.observation,
                SemanticInlineTraitAssignment(trait: trait, enabled: enabled))
        }
        else
        {
            command = .inline(projection.observation,
                SemanticInlineTraitChange(range: range, trait: trait,
                                           enabled: enabled))
        }
        return submitFormatting(command, in: view)
    }
}
