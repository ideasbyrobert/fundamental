import Testing

@testable import FundamentalDocument

extension SemanticTableCellTests
{
    @Test("plain text joins current run text without separators")
    func plainTextJoinsCurrentRunTextWithoutSeparators() throws
    {
        let decomposed = "e\u{301}"
        let link = try #require(
            SemanticLinkDestination("chapter two")
        )
        let language = try #require(
            SemanticLanguageIdentifier("hy")
        )
        var cell = SemanticTableCell(
            runs: [
                SemanticRun(
                    text: "First ",
                    traits: [.strong]
                ),
                SemanticRun(text: ""),
                .scoped(SemanticScopedRun(
                    text: "\(decomposed)\nԲարև 😀",
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
            alignment: .center,
            sourceLocation: "table:1:1",
            confidence: 0.5
        )
        let unchanged = cell
        let expected = "First \(decomposed)\nԲարև 😀"

        #expect(SemanticTableCell(runs: []).plainText.isEmpty)
        #expect(cell.plainText == expected)
        #expect(
            cell.plainText.unicodeScalars.map(\.value)
                == expected.unicodeScalars.map(\.value)
        )
        #expect(cell == unchanged)

        cell.runs[0] = SemanticRun(text: "Changed ")
        cell.runs.swapAt(0, 2)
        cell.runs.append(SemanticRun(text: "!"))

        #expect(
            cell.plainText
                == "\(decomposed)\nԲարև 😀Changed !"
        )
    }
}
