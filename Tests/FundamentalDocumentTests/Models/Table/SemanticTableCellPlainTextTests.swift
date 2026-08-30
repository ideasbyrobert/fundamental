import Testing

@testable import FundamentalDocument

extension SemanticTableCellTests
{
    @Test("plain text joins current run text without separators")
    func plainTextJoinsCurrentRunTextWithoutSeparators()
    {
        let decomposed = "e\u{301}"
        var cell = SemanticTableCell(
            runs: [
                SemanticRun(
                    text: "First ",
                    traits: [.strong]
                ),
                SemanticRun(text: ""),
                SemanticRun(
                    text: "\(decomposed)\nԲարև 😀",
                    traits: [.emphasis],
                    link: "chapter two",
                    language: "hy"
                )
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

        cell.runs[0].text = "Changed "
        cell.runs.swapAt(0, 2)
        cell.runs.append(SemanticRun(text: "!"))

        #expect(
            cell.plainText
                == "\(decomposed)\nԲարև 😀Changed !"
        )
    }
}
