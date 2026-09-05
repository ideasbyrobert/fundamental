import Testing

@testable import FundamentalDocument

extension DocumentHistoryTests
{
    @Test
    func restorationRefusesForeignIdentityAndExhaustedCounters() throws
    {
        let fixture = try HistoryRestorationTestDocument()
        let invalid = [
            try SessionTestDocument(marker: 9),
            try SessionTestDocument(revision: UInt64.max),
            try SessionTestDocument(generation: UInt64.max)
        ]
        for current in invalid
        {
            #expect(RestoredDocumentHistoryCheckpoint(
                fixture.checkpoint,
                in: current.editable.snapshot
            ) == nil)
        }
        #expect(fixture.checkpoint.snapshot.snapshot.document.revision.value
            == 9)
        #expect(fixture.current.document.revision.value == 90)
    }
}
