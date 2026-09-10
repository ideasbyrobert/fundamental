import Foundation
import FundamentalDocument

extension WritingProjection
{
    var selectedLink: SemanticLinkDestination?
    {
        if selection.length == 0
        {
            guard let span = map.spans.first(where:
                { selection.location >= $0.range.location &&
                    selection.location <= NSMaxRange($0.range) }),
                  span.range.length > 0
            else
            {
                return nil
            }
            return link(at: max(span.range.location, selection.location - 1))
        }
        guard let selected = WritingSelectedAttributes(self),
              case let .link(destination) = WritingScopeSelection(
                  kind: .link, in: selected
              ).uniform
        else
        {
            return nil
        }
        return destination
    }

    func link(at index: Int) -> SemanticLinkDestination?
    {
        guard index >= 0, index < map.utf16Count,
              let position = map.spans.firstIndex(where:
            { NSLocationInRange(index, $0.range) }),
              let block = EditableSemanticBlock(
                  snapshot.snapshot.document.content.blocks[position].block
              )
        else
        {
            return nil
        }
        var offset = map.spans[position].range.location
        for run in block.runs
        {
            offset += run.text.utf16.count
            if index < offset
            {
                guard case let .link(destination) =
                    WritingScopeKind.link.assignment(in: run.attributes)
                else
                {
                    return nil
                }
                return destination
            }
        }
        return nil
    }
}
