import Foundation
import Testing

@testable import FundamentalDocument

@Suite("A legacy semantic table cell")
struct LegacySemanticTableCellTests
{
    @Test("required fields and unknown keys decode exactly")
    func requiredFieldsAndUnknownKeysDecodeExactly() throws
    {
        let data = Data(
            #"""
            {
                "runs": [{"text": "Բարև 😀", "traits": ["strong"]}],
                "isHeader": true,
                "rowSpan": 2,
                "columnSpan": 3,
                "alignment": "trailing",
                "sourceLocation": "  table:2:3  ",
                "confidence": 0.75,
                "unknown": "preserved compatibility"
            }
            """#.utf8
        )
        let cell = try JSONDecoder().decode(
            LegacySemanticTableCell.self,
            from: data
        )

        #expect(cell.runs == [
            SemanticRun(text: "Բարև 😀", traits: [.strong])
        ])
        #expect(cell.isHeader)
        #expect(cell.rowSpan == 2)
        #expect(cell.columnSpan == 3)
        #expect(cell.alignment == .trailing)
        #expect(cell.sourceLocation == "  table:2:3  ")
        #expect(cell.confidence == 0.75)
    }

    @Test("missing and null locations decode as transport absence")
    func missingAndNullLocationsDecodeAsTransportAbsence() throws
    {
        let missing = Data(
            #"""
            {
                "runs": [],
                "isHeader": false,
                "rowSpan": 1,
                "columnSpan": 1,
                "alignment": "unspecified",
                "confidence": 1
            }
            """#.utf8
        )
        let null = Data(
            #"""
            {
                "runs": [],
                "isHeader": false,
                "rowSpan": 1,
                "columnSpan": 1,
                "alignment": "unspecified",
                "sourceLocation": null,
                "confidence": 1
            }
            """#.utf8
        )

        for data in [missing, null]
        {
            let cell = try JSONDecoder().decode(
                LegacySemanticTableCell.self,
                from: data
            )
            #expect(cell.sourceLocation == nil)
        }
    }
}
