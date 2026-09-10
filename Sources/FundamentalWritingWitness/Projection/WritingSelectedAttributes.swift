import Foundation
import FundamentalDocument

struct WritingSelectedAttributes: Equatable, Sendable
{
    let values: [SemanticRunAttributes]

    init?(_ projection: WritingProjection)
    {
        let selected = projection.selection
        if selected.length == 0
        {
            guard let attributes = projection.snapshot.typingAttributes(
                in: projection.snapshot.selection.range
            )
            else
            {
                return nil
            }
            values = [attributes]
            return
        }
        let blocks = projection.snapshot.snapshot.document.content.blocks
        var values: [SemanticRunAttributes] = []
        for (index, span) in projection.map.spans.enumerated()
        {
            let lower = max(selected.location, span.range.location)
            let upper = min(NSMaxRange(selected), NSMaxRange(span.range))
            guard lower < upper
            else
            {
                continue
            }
            guard let block = EditableSemanticBlock(blocks[index].block),
                  let start = DocumentUTF16Offset(lower - span.range.location),
                  let end = DocumentUTF16Offset(upper - span.range.location),
                  let partition = SemanticRunPartition(runs: block.runs,
                      lowerBound: start, upperBound: end)
            else
            {
                return nil
            }
            values += partition.selected.filter { !$0.text.isEmpty }
                .map(\.attributes)
        }
        guard !values.isEmpty
        else
        {
            return nil
        }
        self.values = values
    }
}
