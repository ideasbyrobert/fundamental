import Foundation

struct WritingComposition
{
    let baseline: WritingProjection
    let range: NSRange
    let replacement: String
    let markedRange: NSRange
    let selection: NSRange

    var text: String
    {
        (baseline.text as NSString).replacingCharacters(
            in: range, with: replacement
        )
    }

    var proposal: WritingTextProposal?
    {
        WritingTextProposal(ranges: [range], replacements: [replacement],
                            in: baseline)
    }

    static func starting(
        at range: NSRange, in baseline: WritingProjection
    ) -> Self?
    {
        guard baseline.range(range) != nil,
              WritingCompositionRange.valid(range, in: baseline.text)
        else
        {
            return nil
        }
        return Self(
            baseline: baseline, range: range,
            replacement: (baseline.text as NSString).substring(with: range),
            markedRange: range, selection: baseline.selection
        )
    }
}
