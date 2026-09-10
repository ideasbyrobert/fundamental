import AppKit
import FundamentalPresentation

extension MacAccessibilityTree
{
    static func elements(
        residents: [PresentedResident],
        view: NSView,
        horizontalInset: Double
    ) -> [MacAccessibilityElement]
    {
        var result: [MacAccessibilityElement] = []
        var listIDs: Set<UUID> = []
        let lists = listGroups(residents)
        for resident in residents
        {
            switch resident.content
            {
            case let .body(line):
                result.append(element(
                    .body(line.text),
                    resident: resident,
                    view: view,
                    horizontalInset: horizontalInset
                ))
            case let .title(line):
                result.append(element(
                    .title(line.text),
                    resident: resident,
                    view: view,
                    horizontalInset: horizontalInset
                ))
            case let .section(level, line):
                result.append(element(
                    .section(level: level.rawValue, value: line.text),
                    resident: resident,
                    view: view,
                    horizontalInset: horizontalInset
                ))
            case let .code(line):
                result.append(element(
                    .code(line.text),
                    resident: resident,
                    view: view,
                    horizontalInset: horizontalInset
                ))
            case .list:
                let id = resident.residentID.blockID
                if listIDs.insert(id).inserted,
                   let fragments = lists[id],
                   let group = listItem(
                       fragments, view: view,
                       horizontalInset: horizontalInset
                   )
                {
                    result.append(group)
                }
            case .caption:
                break
            case .table:
                result.append(table(
                    resident,
                    residents: residents,
                    view: view,
                    horizontalInset: horizontalInset
                ))
            case .tableColumn,
                 .headerRow,
                 .bodyRow,
                 .headerCell,
                 .bodyCell:
                break
            }
        }
        return result
    }
}
