import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticTableCellTests
{
    @Test("a full cell round trips with the exact coding keys")
    func fullCellRoundTripsWithExactCodingKeys() throws
    {
        let link = try #require(
            SemanticLinkDestination("chapter two")
        )
        let language = try #require(
            SemanticLanguageIdentifier("hy")
        )
        let cell = SemanticTableCell(
            runs: [
                SemanticRun(
                    text: "First",
                    traits: [.strong]
                ),
                .scoped(SemanticScopedRun(
                    text: "Բարև 😀",
                    traits: [.emphasis],
                    scopes: .linkAndLanguage(
                        link: link,
                        language: language
                    )
                ))
            ],
            isHeader: true,
            rowSpan: 2,
            columnSpan: 3,
            alignment: .trailing,
            sourceLocation: "table:2:3",
            confidence: 0.75
        )
        let data = try JSONEncoder().encode(cell)
        let decoded = try JSONDecoder().decode(
            SemanticTableCell.self,
            from: data
        )
        let object = try encodedObject(for: cell)

        #expect(decoded == cell)
        #expect(Set(object.keys) == Set([
            "alignment",
            "columnSpan",
            "confidence",
            "isHeader",
            "rowSpan",
            "runs",
            "sourceLocation"
        ]))

        let withoutLocation = try encodedObject(
            for: SemanticTableCell(runs: [])
        )

        #expect(Set(withoutLocation.keys) == Set([
            "alignment",
            "columnSpan",
            "confidence",
            "isHeader",
            "rowSpan",
            "runs"
        ]))
    }

    private func encodedObject(
        for cell: SemanticTableCell
    ) throws -> [String: Any]
    {
        let data = try JSONEncoder().encode(cell)
        return try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
    }
}
