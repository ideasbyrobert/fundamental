import Testing
@testable import FundamentalDocument
extension SemanticTableCellAdmissionTests
{
    @Test("nonpositive spans normalize independently with repairs")
    func nonpositiveSpansNormalizeIndependentlyWithRepairs() throws
    {
        let cases: [(Int, Int, [SemanticTableRepairKind])] = [
            (0, 2, [.nonpositiveRowSpanNormalizedToOne]),
            (2, -1, [.nonpositiveColumnSpanNormalizedToOne]),
            (
                0,
                -1,
                [
                    .nonpositiveRowSpanNormalizedToOne,
                    .nonpositiveColumnSpanNormalizedToOne
                ]
            )
        ]
        let (row, cell) = try Self.indices()
        let target = SemanticTableEvidenceTarget.cell(
            row: row,
            cell: cell
        )
        for (rowSpan, columnSpan, expectedKinds) in cases
        {
            let admission = try Self.admit(
                Self.legacy(
                    rowSpan: rowSpan,
                    columnSpan: columnSpan
                )
            )
            let actualKinds: [SemanticTableRepairKind] =
                admission.evidence.compactMap
            { fact -> SemanticTableRepairKind? in
                guard case let .repair(repair) = fact
                else
                {
                    return nil
                }
                #expect(repair.target == target)
                return repair.kind
            }
            #expect(actualKinds.count == expectedKinds.count)
            for kind in expectedKinds
            {
                #expect(actualKinds.contains(kind))
            }
            #expect(admission.cell.rowCount == max(1, rowSpan))
            #expect(admission.cell.columnCount == max(1, columnSpan))
        }
    }
    @Test("invalid confidence refuses complete admission")
    func invalidConfidenceRefusesCompleteAdmission() throws
    {
        let values = [
            Double.nan,
            Double.infinity,
            -Double.infinity,
            -Double.leastNonzeroMagnitude,
            1.0.nextUp
        ]
        let (row, cell) = try Self.indices()
        for value in values
        {
            #expect(
                SemanticTableCellAdmissionAdapter.admit(
                    Self.legacy(confidence: value),
                    rowIndex: row,
                    cellIndex: cell
                ) == nil
            )
        }
    }
    @Test("runs scopes and alignment survive admission exactly")
    func runsScopesAndAlignmentSurviveAdmissionExactly() throws
    {
        let link = try #require(SemanticLinkDestination("chapter two"))
        let runs: [SemanticRun] = [
            SemanticRun(text: "First", traits: [.strong]),
            .scoped(SemanticScopedRun(
                text: "Բարև 😀",
                traits: [.emphasis],
                scopes: .link(link)
            ))
        ]
        let admission = try Self.admit(
            Self.legacy(
                runs: runs,
                alignment: .trailing
            )
        )
        #expect(admission.cell.runs == runs)
        #expect(admission.cell.alignment == .trailing)
    }
}
