import Foundation
import FundamentalDocument

extension WritingComposition
{
    static func starting(
        at range: NSRange, in baseline: WritingProjection
    ) -> Self?
    {
        guard let selected = baseline.range(range),
              let source = WritingRunSequence(baseline),
              let divided = source.partition(range),
              let attributes = baseline.snapshot.typingIntent?.attributes ??
                  baseline.snapshot.typingAttributes(in: selected),
              WritingCompositionRange.valid(range, in: baseline.text)
        else
        {
            return nil
        }
        let result = Self(baseline: baseline, source: source, range: range,
            replacement: WritingRunSequence(divided.selected),
            markedRange: range, selection: baseline.selection,
            attributes: attributes)
        return result.input == nil ? nil : result
    }
}
