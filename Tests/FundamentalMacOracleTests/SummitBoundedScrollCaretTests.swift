import FundamentalPresentation

extension SummitBoundedScrollTests
{
    static func caretCount(
        _ content: PresentedResidentContent
    ) -> Int
    {
        switch content
        {
        case let .body(line),
             let .title(line),
             let .code(line),
             let .caption(line),
             let .section(_, line):
            return line.caretSites.count
        case let .headerCell(_, _, .line(line)),
             let .bodyCell(_, _, .line(line)):
            return line.caretSites.count
        default:
            return 0
        }
    }
}
