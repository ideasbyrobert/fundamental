import Foundation
import Testing

@testable import FundamentalDocument

@Suite("A legacy semantic table")
struct LegacySemanticTableTests
{
    @Test("required fields and unknown keys decode exactly")
    func requiredFieldsAndUnknownKeysDecodeExactly() throws
    {
        let data = Data(
            #"""
            {
                "rows": [{
                    "cells": [],
                    "sourceLocation": "  row:0  "
                }],
                "headerRowCount": 1,
                "columnAlignments": ["leading", "leading"],
                "caption": [{"text": "Բարև 😀", "traits": []}],
                "sourceLocation": "  table:1  ",
                "confidence": 0.75,
                "unknownTable": true
            }
            """#.utf8
        )
        let table = try JSONDecoder().decode(
            LegacySemanticTable.self,
            from: data
        )

        #expect(table.rows.count == 1)
        #expect(table.rows[0].sourceLocation == "  row:0  ")
        #expect(table.headerRowCount == 1)
        #expect(table.columnAlignments == [.leading, .leading])
        #expect(table.caption == [SemanticRun(text: "Բարև 😀")])
        #expect(table.sourceLocation == "  table:1  ")
        #expect(table.confidence == 0.75)
    }

    @Test("missing and null optionals decode as transport absence")
    func missingAndNullOptionalsDecodeAsTransportAbsence() throws
    {
        let missing = Data(
            #"""
            {"rows": [], "headerRowCount": 0,
             "columnAlignments": [], "confidence": 1}
            """#.utf8
        )
        let null = Data(
            #"""
            {"rows": [], "headerRowCount": 0,
             "columnAlignments": [], "caption": null,
             "sourceLocation": null, "confidence": 1}
            """#.utf8
        )

        for data in [missing, null]
        {
            let table = try JSONDecoder().decode(
                LegacySemanticTable.self,
                from: data
            )
            #expect(table.caption == nil)
            #expect(table.sourceLocation == nil)
        }
    }
}
