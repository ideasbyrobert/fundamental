import Foundation
import Testing

@testable import FundamentalDocument

@Suite("A legacy semantic table row")
struct LegacySemanticTableRowTests
{
    @Test("required cells and unknown keys decode exactly")
    func requiredCellsAndUnknownKeysDecodeExactly() throws
    {
        let data = Data(
            #"""
            {
                "cells": [{
                    "runs": [{"text": "Բարև 😀", "traits": []}],
                    "isHeader": true,
                    "rowSpan": 1,
                    "columnSpan": 1,
                    "alignment": "leading",
                    "confidence": 0.75,
                    "unknownCell": true
                }],
                "sourceLocation": "  row:2  ",
                "unknownRow": true
            }
            """#.utf8
        )
        let row = try JSONDecoder().decode(
            LegacySemanticTableRow.self,
            from: data
        )

        #expect(row.cells.count == 1)
        #expect(row.cells[0].runs == [SemanticRun(text: "Բարև 😀")])
        #expect(row.cells[0].isHeader)
        #expect(row.cells[0].alignment == .leading)
        #expect(row.cells[0].confidence == 0.75)
        #expect(row.sourceLocation == "  row:2  ")
    }

    @Test("missing and null locations decode as transport absence")
    func missingAndNullLocationsDecodeAsTransportAbsence() throws
    {
        let missing = Data(#"{"cells": []}"#.utf8)
        let null = Data(
            #"{"cells": [], "sourceLocation": null}"#.utf8
        )

        for data in [missing, null]
        {
            let row = try JSONDecoder().decode(
                LegacySemanticTableRow.self,
                from: data
            )
            #expect(row.sourceLocation == nil)
        }
    }
}
