import Foundation
import FundamentalPresentation
import Testing

extension SummitCorpusTests
{
    @Test("both table forms reach presentation without flattening")
    func tableWitnessesReachPresentation() throws
    {
        let residents = try MacSummitScan().residents
        var tables = Set<UUID>()
        var captions = Set<UUID>()
        var headerRows = 0
        var bodyRows = 0
        var hasSpan = false
        for resident in residents
        {
            switch resident.content
            {
            case .table:
                tables.insert(resident.residentID.blockID)
            case .caption:
                captions.insert(resident.residentID.blockID)
            case .headerRow:
                headerRows += 1
            case .bodyRow:
                bodyRows += 1
            case let .bodyCell(_, _, .area(geometry)):
                hasSpan = hasSpan
                    || geometry.rowSpan > 1
                    || geometry.columnSpan > 1
            default:
                break
            }
        }
        #expect(tables.count == 2)
        #expect(captions.count == 1)
        #expect(captions.isSubset(of: tables))
        #expect(headerRows == 2)
        #expect(bodyRows == 2)
        #expect(hasSpan)
    }
}
