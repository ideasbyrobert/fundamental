import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticTableCellTests
{
    @Test("compatible payloads preserve decoded spans and optionals")
    func compatiblePayloadsPreserveDecodedSpansAndOptionals() throws
    {
        let absentLocation = Data(
            #"""
            {
                "runs": [{"text": "Body", "traits": []}],
                "isHeader": false,
                "rowSpan": 0,
                "columnSpan": -2,
                "alignment": "unspecified",
                "confidence": 1
            }
            """#.utf8
        )
        let decoded = try JSONDecoder().decode(
            SemanticTableCell.self,
            from: absentLocation
        )

        #expect(decoded.runs == [SemanticRun(text: "Body")])
        #expect(decoded.rowSpan == 0)
        #expect(decoded.columnSpan == -2)
        #expect(decoded.sourceLocation == nil)

        let nullLocation = Data(
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
        let decodedNull = try JSONDecoder().decode(
            SemanticTableCell.self,
            from: nullLocation
        )

        #expect(decodedNull.sourceLocation == nil)
    }

    @Test("missing required fields are refused")
    func missingRequiredFieldsAreRefused() throws
    {
        let complete: [String: Any] = [
            "runs": [],
            "isHeader": false,
            "rowSpan": 1,
            "columnSpan": 1,
            "alignment": "unspecified",
            "confidence": 1
        ]
        let requiredKeys = [
            "runs",
            "isHeader",
            "rowSpan",
            "columnSpan",
            "alignment",
            "confidence"
        ]

        for key in requiredKeys
        {
            var incomplete = complete
            incomplete.removeValue(forKey: key)
            let data = try JSONSerialization.data(
                withJSONObject: incomplete
            )

            #expect(throws: DecodingError.self)
            {
                try JSONDecoder().decode(
                    SemanticTableCell.self,
                    from: data
                )
            }
        }
    }
}
