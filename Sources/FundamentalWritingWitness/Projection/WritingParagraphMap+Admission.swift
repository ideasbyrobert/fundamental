import FundamentalDocument

extension WritingParagraphMap
{
    static func spelling(
        _ block: SemanticBlock, startingAt initial: Int
    ) -> String?
    {
        guard initial <= WritingSurfacePolicy.maximumUTF16Units
        else
        {
            return nil
        }
        let runs: [SemanticRun]
        switch block
        {
        case let .paragraph(paragraph):
            runs = paragraph.runs
        case let .heading(heading):
            runs = heading.runs
        case let .listItem(item):
            runs = item.runs
        case let .code(.plain(code)):
            runs = code.runs
        case let .code(.languageTagged(code)):
            runs = code.runs
        case .table:
            return nil
        }
        var count = initial
        for run in runs
        {
            guard case .direct = run,
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
        return runs.map(\.text).joined()
    }
}
