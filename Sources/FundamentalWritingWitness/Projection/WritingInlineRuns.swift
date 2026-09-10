import AppKit
import FundamentalDocument

@MainActor
enum WritingInlineRuns
{
    static func apply(
        _ runs: [SemanticRun], to text: NSMutableAttributedString,
        in range: NSRange, font: NSFont
    ) -> Bool
    {
        var offset = range.location
        for run in runs
        {
            let length = run.text.utf16.count
            guard length <= NSMaxRange(range) - offset,
                  let attributes = WritingRunAppearance.attributes(
                      run.attributes, font: font
                  )
            else
            {
                return false
            }
            if length > 0
            {
                text.addAttributes(attributes, range: NSRange(
                    location: offset, length: length
                ))
            }
            offset += length
        }
        return offset == NSMaxRange(range)
    }
}
