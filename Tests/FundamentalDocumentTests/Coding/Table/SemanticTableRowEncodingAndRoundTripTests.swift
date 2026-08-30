import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticTableRowTests
{
    @Test("a full row round trips with the exact coding keys")
    func fullRowRoundTripsWithExactCodingKeys() throws
    {
        let row = SemanticTableRow(
            cells: [
                SemanticTableCell(
                    runs: [SemanticRun(text: "First")]
                ),
                SemanticTableCell(
                    runs: [SemanticRun(text: "Second")],
                    isHeader: true
                )
            ],
            sourceLocation: "table:2"
        )
        let data = try JSONEncoder().encode(row)
        let decoded = try JSONDecoder().decode(
            SemanticTableRow.self,
            from: data
        )
        let object = try encodedObject(for: row)

        #expect(decoded == row)
        #expect(Set(object.keys) == Set([
            "cells",
            "sourceLocation"
        ]))

        let withoutLocation = try encodedObject(
            for: SemanticTableRow(cells: [])
        )

        #expect(Set(withoutLocation.keys) == Set(["cells"]))
    }

    private func encodedObject(
        for row: SemanticTableRow
    ) throws -> [String: Any]
    {
        let data = try JSONEncoder().encode(row)
        return try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
    }
}
