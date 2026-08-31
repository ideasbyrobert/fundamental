import Testing

@testable import FundamentalDocument

extension SemanticTableAdmissionTests
{
    @Test("clamped header counts record one exact repair")
    func clampedHeaderCountsRecordOneExactRepair() throws
    {
        let cases = [
            (raw: -2, rowCount: 2, admitted: 0),
            (raw: Int.min, rowCount: 2, admitted: 0),
            (raw: 3, rowCount: 2, admitted: 2),
            (raw: Int.max, rowCount: 2, admitted: 2),
            (raw: 1, rowCount: 0, admitted: 0)
        ]
        let repair = try #require(SemanticTableRepair(
            target: .table,
            kind: .headerRowCountClamped
        ))
        for value in cases
        {
            let rows = (0 ..< value.rowCount).map
            {
                Self.row("Row \($0)")
            }
            let admission = try Self.admit(Self.table(
                rows: rows,
                headerRowCount: value.raw
            ))
            let repairs = admission.evidence.filter
            {
                $0 == .repair(repair)
            }
            #expect(repairs == [.repair(repair)])
            #expect(
                admission.table.content.headerRows.count
                    == value.admitted
            )
        }
    }

    @Test("invalid table confidence refuses every partial result")
    func invalidTableConfidenceRefusesEveryPartialResult()
    {
        let values = [
            -Double.leastNonzeroMagnitude,
            1.0.nextUp,
            .nan,
            .infinity,
            -.infinity
        ]

        for value in values
        {
            let legacy = Self.table(
                rows: [Self.row("Valid")],
                confidence: value
            )
            #expect(
                SemanticTableAdmissionAdapter.admit(legacy) == nil
            )
        }
    }

    @Test("one invalid nested row refuses every partial result")
    func oneInvalidNestedRowRefusesEveryPartialResult()
    {
        let legacy = Self.table(rows: [
            Self.row("Valid"),
            Self.row("Invalid", confidence: 2)
        ])

        #expect(SemanticTableAdmissionAdapter.admit(legacy) == nil)
    }
}
