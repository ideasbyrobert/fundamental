import Foundation
import Testing

@testable import FundamentalDocument

extension LegacySemanticTableRecordCodecTests
{
    @Test("an overreaching legacy row span refuses the record")
    func overreachingLegacyRowSpanRefusesRecord()
    {
        let data = Self.rowSpanData(rowSpan: 2, rowCount: 1)

        do
        {
            _ = try SemanticTableRecordCodec.decode(data)
            Issue.record("Expected complete legacy refusal")
        }
        catch
        {
        }
    }

    @Test("a legacy row span may cross the header body boundary")
    func legacyRowSpanMayCrossHeaderBodyBoundary() throws
    {
        let record = try SemanticTableRecordCodec.decode(
            Self.rowSpanData(rowSpan: 2, rowCount: 2)
        )

        #expect(record.table.content.headerRows.count == 1)
        #expect(record.table.content.bodyRows.count == 1)
        #expect(record.table.content.headerRows[0].cells[0].rowCount == 2)
    }

    private static func rowSpanData(
        rowSpan: Int,
        rowCount: Int
    ) -> Data
    {
        let cell =
            #"{"alignment":"leading","columnSpan":1,"confidence":1,"#
            + #""isHeader":true,"rowSpan":\#(rowSpan),"runs":[]}"#
        let occupiedRow = #"{"cells":[\#(cell)]}"#
        let emptyRow = #"{"cells":[]}"#
        let rows = rowCount == 1
            ? occupiedRow
            : occupiedRow + "," + emptyRow
        let root =
            #"{"columnAlignments":[],"confidence":1,"#
            + #""headerRowCount":1,"rows":[\#(rows)]}"#
        return Data(root.utf8)
    }
}
