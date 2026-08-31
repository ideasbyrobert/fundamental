import Testing

@testable import FundamentalDocument

extension SemanticTableCellTests
{
    @Test("reconstruction leaves the original cell unchanged")
    func reconstructionLeavesOriginalCellUnchanged()
    {
        let original = SemanticTableCell.regular(
            RegularSemanticTableCell(
                runs: [SemanticRun(text: "Body")]
            )
        )
        let changed = SemanticTableCell.regular(
            RegularSemanticTableCell(
                runs: [SemanticRun(text: "Changed")],
                alignment: .center
            )
        )

        #expect(original != changed)
        #expect(original.runs == [SemanticRun(text: "Body")])
        #expect(original.alignment == .unspecified)
    }
}
