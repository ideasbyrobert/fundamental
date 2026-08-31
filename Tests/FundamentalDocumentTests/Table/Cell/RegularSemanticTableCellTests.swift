import Testing

@testable import FundamentalDocument

@Suite("A regular semantic table cell")
struct RegularSemanticTableCellTests
{
    @Test("initialization preserves immutable facts")
    func initializationPreservesImmutableFacts()
    {
        let runs = [
            SemanticRun(text: "First"),
            SemanticRun(text: "Second", traits: [.strong])
        ]
        let cell = RegularSemanticTableCell(
            runs: runs,
            alignment: .trailing
        )

        #expect(cell.runs == runs)
        #expect(cell.alignment == .trailing)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged()
    {
        let original = RegularSemanticTableCell(
            runs: [SemanticRun(text: "Body")]
        )
        let changed = RegularSemanticTableCell(
            runs: [SemanticRun(text: "Changed")],
            alignment: .center
        )

        #expect(original != changed)
        #expect(original.runs == [SemanticRun(text: "Body")])
        #expect(original.alignment == .unspecified)
    }
}
