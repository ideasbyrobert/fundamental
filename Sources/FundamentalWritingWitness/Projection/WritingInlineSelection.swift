import Foundation
import FundamentalDocument

struct WritingInlineSelection: Equatable, Sendable
{
    let values: [Set<SemanticInlineTrait>]

    init?(_ projection: WritingProjection)
    {
        let selected = projection.selection
        if selected.length == 0
        {
            guard case let .direct(traits) = projection.snapshot
                .typingAttributes(in: projection.snapshot.selection.range)
            else
            {
                return nil
            }
            values = [traits]
            return
        }
        let blocks = projection.snapshot.snapshot.document.content.blocks
        var values: [Set<SemanticInlineTrait>] = []
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
            for run in partition.selected where !run.text.isEmpty
            {
                values.append(run.traits)
            }
        }
        guard !values.isEmpty
        else
        {
            return nil
        }
        self.values = values
    }

    func state(of trait: SemanticInlineTrait) -> WritingInlineState
    {
        let count = values.filter { $0.contains(trait) }.count
        return count == 0 ? .off : count == values.count ? .on : .mixed
    }
}
