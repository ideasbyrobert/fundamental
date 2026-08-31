import Foundation
import Testing

@testable import FundamentalDocument

extension LegacySemanticTableRowTests
{
    @Test("missing null and wrong-typed cell collections are refused")
    func missingNullAndWrongTypedCellCollectionsAreRefused() throws
    {
        let objects: [[String: Any]] = [
            [:],
            ["cells": NSNull()],
            ["cells": "not cells"]
        ]

        for object in objects
        {
            try expectRefusal(of: object)
        }
    }

    @Test("malformed cells and wrong-typed locations are refused")
    func malformedCellsAndWrongTypedLocationsAreRefused() throws
    {
        let malformedCell: [String: Any] = [
            "runs": [],
            "isHeader": false,
            "rowSpan": 1,
            "columnSpan": 1,
            "alignment": "unspecified"
        ]
        let objects: [[String: Any]] = [
            ["cells": [malformedCell]],
            ["cells": [], "sourceLocation": 4]
        ]

        for object in objects
        {
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
                LegacySemanticTableRow.self,
                from: data
            )
        }
    }
}
