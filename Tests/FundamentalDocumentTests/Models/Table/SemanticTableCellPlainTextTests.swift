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
        let regular = SemanticTableCell.regular(
            RegularSemanticTableCell(runs: [
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
            ])
        )
        let extent = try #require(
            SemanticTableCellExtent(
                rowCount: 2,
                columnCount: 3
            )
        )
        let spanning = SemanticTableCell.spanning(
            SpanningSemanticTableCell(
                runs: regular.runs,
                alignment: .center,
                extent: extent
            )
        )
        let expected = "First \(decomposed)\nԲարև 😀"

        #expect(
            SemanticTableCell.regular(
                RegularSemanticTableCell(runs: [])
            ).plainText.isEmpty
        )
        #expect(regular.plainText == expected)
        #expect(spanning.plainText == expected)
        #expect(
            regular.plainText.unicodeScalars.map(\.value)
                == expected.unicodeScalars.map(\.value)
        )
    }
}
