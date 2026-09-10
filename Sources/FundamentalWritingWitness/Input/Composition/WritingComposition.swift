import Foundation
import FundamentalDocument

struct WritingComposition
{
    let baseline: WritingProjection
    let source: WritingRunSequence
    let range: NSRange
    let replacement: WritingRunSequence
    let markedRange: NSRange
    let selection: NSRange
    let attributes: SemanticRunAttributes
    let input: WritingCompositionInput?

    var text: String
    {
        (baseline.text as NSString).replacingCharacters(
            in: range, with: replacement.text
        )
    }

    init(
        baseline: WritingProjection, source: WritingRunSequence,
        range: NSRange, replacement: WritingRunSequence,
        markedRange: NSRange, selection: NSRange,
        attributes: SemanticRunAttributes
    )
    {
        self.baseline = baseline
        self.source = source
        self.range = range
        self.replacement = replacement
        self.markedRange = markedRange
        self.selection = selection
        self.attributes = attributes
        let unchanged = source.replacing(range, with: replacement.runs)?
            .matches(source) == true
        input = WritingCompositionInput(baseline: baseline, range: range,
            replacement: replacement, selection: selection,
            attributes: attributes, unchanged: unchanged)
    }
}
