import Testing

@testable import FundamentalDocument

@Suite("A semantic table cell")
struct SemanticTableCellTests
{
    @Test("minimal initialization uses the exact defaults")
    func minimalInitializationUsesDefaults()
    {
        let cell = SemanticTableCell(runs: [])

        #expect(cell.runs.isEmpty)
        #expect(cell.isHeader == false)
        #expect(cell.rowSpan == 1)
        #expect(cell.columnSpan == 1)
        #expect(cell.alignment == .unspecified)
        #expect(cell.sourceLocation == nil)
        #expect(cell.confidence == 1)
    }

    @Test("full initialization preserves supplied values and run order")
    func fullInitializationPreservesValuesAndRunOrder()
    {
        let runs = [
            SemanticRun(
                text: "First",
                traits: [.strong]
            ),
            SemanticRun(
                text: "Բարև 😀",
                traits: [.emphasis],
                link: "chapter two",
                language: "hy"
            )
        ]
        let cell = SemanticTableCell(
            runs: runs,
            isHeader: true,
            rowSpan: 2,
            columnSpan: 3,
            alignment: .trailing,
            sourceLocation: "table:2:3",
            confidence: 0.75
        )

        #expect(cell.runs == runs)
        #expect(cell.isHeader)
        #expect(cell.rowSpan == 2)
        #expect(cell.columnSpan == 3)
        #expect(cell.alignment == .trailing)
        #expect(cell.sourceLocation == "table:2:3")
        #expect(cell.confidence == 0.75)
    }

    @Test("span inputs clamp only at construction")
    func spanInputsClampOnlyAtConstruction()
    {
        let zeroRowSpan = SemanticTableCell(
            runs: [],
            rowSpan: 0,
            columnSpan: -3
        )
        let negativeRowSpan = SemanticTableCell(
            runs: [],
            rowSpan: -3,
            columnSpan: 0
        )
        let boundary = SemanticTableCell(
            runs: [],
            rowSpan: 1,
            columnSpan: 1
        )
        let positive = SemanticTableCell(
            runs: [],
            rowSpan: 4,
            columnSpan: 5
        )

        #expect(zeroRowSpan.rowSpan == 1)
        #expect(zeroRowSpan.columnSpan == 1)
        #expect(negativeRowSpan.rowSpan == 1)
        #expect(negativeRowSpan.columnSpan == 1)
        #expect(boundary.rowSpan == 1)
        #expect(boundary.columnSpan == 1)
        #expect(positive.rowSpan == 4)
        #expect(positive.columnSpan == 5)
    }

    @Test("every stored field remains mutable")
    func everyStoredFieldRemainsMutable()
    {
        let runs = [SemanticRun(text: "Changed")]
        var cell = SemanticTableCell(runs: [])

        cell.runs = runs
        cell.isHeader = true
        cell.rowSpan = 0
        cell.columnSpan = -2
        cell.alignment = .center
        cell.sourceLocation = "table:4:2"
        cell.confidence = 0.5

        #expect(cell.runs == runs)
        #expect(cell.isHeader)
        #expect(cell.rowSpan == 0)
        #expect(cell.columnSpan == -2)
        #expect(cell.alignment == .center)
        #expect(cell.sourceLocation == "table:4:2")
        #expect(cell.confidence == 0.5)
    }

    @Test("equality observes every stored field")
    func equalityObservesEveryStoredField()
    {
        let cell = SemanticTableCell(
            runs: [SemanticRun(text: "Body")],
            isHeader: true,
            rowSpan: 2,
            columnSpan: 3,
            alignment: .leading,
            sourceLocation: "table:1:1",
            confidence: 0.75
        )
        let identical = SemanticTableCell(
            runs: [SemanticRun(text: "Body")],
            isHeader: true,
            rowSpan: 2,
            columnSpan: 3,
            alignment: .leading,
            sourceLocation: "table:1:1",
            confidence: 0.75
        )
        var changed = cell

        #expect(cell == identical)

        changed.runs = [SemanticRun(text: "Different")]
        #expect(changed != cell)

        changed = cell
        changed.isHeader = false
        #expect(changed != cell)

        changed = cell
        changed.rowSpan = 4
        #expect(changed != cell)

        changed = cell
        changed.columnSpan = 5
        #expect(changed != cell)

        changed = cell
        changed.alignment = .trailing
        #expect(changed != cell)

        changed = cell
        changed.sourceLocation = nil
        #expect(changed != cell)

        changed = cell
        changed.confidence = 0.5
        #expect(changed != cell)
    }

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
