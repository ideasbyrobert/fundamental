import FundamentalPresentation

extension MacRasterExecutor
{
    static func lineOrigins(
        _ residents: PresentedResidentCollection
    ) -> [PresentationResidentID: PresentationPoint]
    {
        var seen: Set<PresentationResidentID> = []
        var origins: [PresentationResidentID: PresentationPoint] = [:]
        for resident in residents.all
        {
            guard seen.insert(resident.residentID).inserted
            else
            {
                origins.removeValue(forKey: resident.residentID)
                continue
            }
            origins[resident.residentID] = lineOrigin(resident.content)
        }
        return origins
    }

    private static func lineOrigin(
        _ content: PresentedResidentContent
    ) -> PresentationPoint?
    {
        switch content
        {
        case let .body(line), let .title(line), let .section(_, line),
             let .code(line), let .caption(line):
            return line.baseline
        case let .headerCell(_, _, content), let .bodyCell(_, _, content):
            if case let .line(line) = content
            {
                return line.baseline
            }
            return nil
        case .table, .tableColumn, .headerRow, .bodyRow:
            return nil
        }
    }
}
