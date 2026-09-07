import Foundation

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
        let current = text
        guard WritingCompositionRange.valid(replaced, in: current),
              current.utf16.count - replaced.length + inserted.utf16.count <=
                  WritingSurfacePolicy.maximumUTF16Units
        else
        {
            return nil
        }
        let lower = min(range.location, replaced.location)
        let priorEnd = range.location + replacement.utf16.count
        let upper = max(priorEnd, NSMaxRange(replaced))
        let originalEnd = NSMaxRange(range) + max(
            0, NSMaxRange(replaced) - priorEnd
        )
        let expanded = NSRange(location: lower, length: originalEnd - lower)
        let region = (current as NSString).substring(with: NSRange(
            location: lower, length: upper - lower
        )) as NSString
        let updated = region.replacingCharacters(in: NSRange(
            location: replaced.location - lower, length: replaced.length
        ), with: inserted)
        let result = Self(
            baseline: baseline, range: expanded, replacement: updated,
            markedRange: NSRange(location: replaced.location,
                                 length: inserted.utf16.count),
            selection: NSRange(location: replaced.location + selecting.location,
                               length: selecting.length)
        )
        guard result.proposal != nil || result.text.utf16.elementsEqual(
            baseline.text.utf16
        )
        else
        {
            return nil
        }
        return result
    }
}
