import Foundation
import Testing

@testable import FundamentalDocument

extension LegacySemanticTableTests
{
    @Test("missing null and wrong-typed required fields are refused")
    func missingNullAndWrongTypedRequiredFieldsAreRefused() throws
    {
        let wrongValues: [String: Any] = [
            "rows": "not rows",
            "headerRowCount": "not a count",
            "columnAlignments": "not alignments",
            "confidence": "not confidence"
        ]

        for (key, wrongValue) in wrongValues
        {
            var missing = validObject()
            missing.removeValue(forKey: key)
            var null = validObject()
            null[key] = NSNull()
            var wrong = validObject()
            wrong[key] = wrongValue

            for object in [missing, null, wrong]
            {
                try expectRefusal(of: object)
            }
        }
    }

    @Test("malformed rows captions and wrong-typed locations are refused")
    func malformedRowsCaptionsAndWrongTypedLocationsAreRefused() throws
    {
        var malformedRows = validObject()
        malformedRows["rows"] = [["cells": [["runs": []]]]]
        var malformedCaption = validObject()
        malformedCaption["caption"] = [4]
        var wrongLocation = validObject()
        wrongLocation["sourceLocation"] = 4
        var unknownAlignment = validObject()
        unknownAlignment["columnAlignments"] = ["diagonal"]

        for object in [
            malformedRows,
            malformedCaption,
            wrongLocation,
            unknownAlignment
        ]
        {
            try expectRefusal(of: object)
        }
    }

    private func validObject() -> [String: Any]
    {
        [
            "rows": [],
            "headerRowCount": 0,
            "columnAlignments": [],
            "confidence": 1
        ]
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
                LegacySemanticTable.self,
                from: data
            )
        }
    }
}
