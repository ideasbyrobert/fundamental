import Testing

@testable import FundamentalDocument

extension CanonicalSemanticTableRecordCodecTests
{
    @Test("an overreaching canonical row span refuses the record")
    func overreachingCanonicalRowSpanRefusesRecord()
    {
        Self.expectRefusal(Self.tableRoot(
            Self.overreachingEvidenceTable
        ))
    }

    @Test("a canonical row span ending at the last row is admitted")
    func canonicalRowSpanEndingAtLastRowIsAdmitted() throws
    {
        let record = try Self.decode(Self.tableRoot(
            Self.tallEvidenceTable
        ))

        #expect(record.table.content.bodyRows.count == 2)
        #expect(record.table.content.bodyRows[0].cells[0].rowCount == 2)
    }
}
