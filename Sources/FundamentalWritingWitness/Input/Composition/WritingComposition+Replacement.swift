import Foundation
import FundamentalDocument

extension WritingComposition
{
    func replacing(
        _ replaced: NSRange, with inserted: String, selecting: NSRange
    ) -> Self?
    {
        guard inserted.utf16.count <= WritingSurfacePolicy.maximumUTF16Units,
              WritingCompositionRange.valid(selecting, in: inserted)
        else
        {
            return nil
        }
        guard let current = source.replacing(range, with: replacement.runs),
              WritingCompositionRange.valid(replaced, in: current.text),
              current.text.utf16.count - replaced.length +
                  inserted.utf16.count <=
                  WritingSurfacePolicy.maximumUTF16Units
        else
        {
            return nil
        }
        let lower = min(range.location, replaced.location)
        let priorEnd = range.location + replacement.text.utf16.count
        let upper = max(priorEnd, NSMaxRange(replaced))
        let originalEnd = NSMaxRange(range) + max(
            0, NSMaxRange(replaced) - priorEnd
        )
        let expanded = NSRange(location: lower, length: originalEnd - lower)
        guard let region = current.partition(NSRange(
            location: lower, length: upper - lower
        ))
        else
        {
            return nil
        }
        let incoming = inserted.isEmpty ? [] : [SemanticRun(
            text: inserted, attributes: attributes
        )]
        let retained = WritingRunSequence(region.selected)
        guard let updated = retained.replacing(NSRange(
            location: replaced.location - lower, length: replaced.length
        ), with: incoming)
        else
        {
            return nil
        }
        let result = Self(
            baseline: baseline, source: source, range: expanded,
            replacement: updated,
            markedRange: NSRange(location: replaced.location,
                                 length: inserted.utf16.count),
            selection: NSRange(location: replaced.location + selecting.location,
                               length: selecting.length), attributes: attributes
        )
        guard result.input != nil
        else
        {
            return nil
        }
        return result
    }
}
