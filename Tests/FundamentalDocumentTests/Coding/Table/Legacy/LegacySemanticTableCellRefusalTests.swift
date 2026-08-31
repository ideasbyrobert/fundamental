import Foundation
import Testing

@testable import FundamentalDocument

extension LegacySemanticTableCellTests
{
    @Test("missing null and malformed required fields are refused")
    func missingNullAndMalformedRequiredFieldsAreRefused() throws
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
            var missing = complete
            missing.removeValue(forKey: key)
            try expectRefusal(of: missing)

            var null = complete
            null[key] = NSNull()
            try expectRefusal(of: null)
        }

        let malformed: [(String, Any)] = [
            ("runs", "not runs"),
            ("runs", [["text": 4, "traits": []]]),
            ("isHeader", "not a Boolean"),
            ("rowSpan", "not an integer"),
            ("columnSpan", 1.5),
            ("alignment", "unknown"),
            ("sourceLocation", 4),
            ("confidence", "not a number")
        ]

        for (key, value) in malformed
        {
            var object = complete
            object[key] = value
            try expectRefusal(of: object)
        }
    }

    private func expectRefusal(
        of object: [String: Any]
    ) throws
    {
        let data = try JSONSerialization.data(
            withJSONObject: object
        )

        #expect(throws: DecodingError.self)
        {
            try JSONDecoder().decode(
                LegacySemanticTableCell.self,
                from: data
            )
        }
    }
}
