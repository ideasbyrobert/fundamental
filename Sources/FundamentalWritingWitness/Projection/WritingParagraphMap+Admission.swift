import FundamentalDocument

extension WritingParagraphMap
{
    static func spelling(
        _ paragraph: SemanticParagraph, startingAt initial: Int
    ) -> String?
    {
        guard initial <= WritingSurfacePolicy.maximumUTF16Units
        else
        {
            return nil
        }
        var count = initial
        for run in paragraph.runs
        {
            guard case .direct = run, run.traits.isEmpty,
                  WritingSurfacePolicy.admits(run.text)
            else
            {
                return nil
            }
            let (next, overflow) = count.addingReportingOverflow(
                run.text.utf16.count
            )
            guard !overflow, next <= WritingSurfacePolicy.maximumUTF16Units
            else
            {
                return nil
            }
            count = next
        }
        return paragraph.runs.map(\.text).joined()
    }
}
