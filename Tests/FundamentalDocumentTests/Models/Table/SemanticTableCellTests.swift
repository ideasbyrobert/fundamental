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
}
