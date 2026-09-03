import Testing

@testable import FundamentalDocument

extension DocumentSessionStateTests
{
    @Test("case generation document and selection participate in equality")
    func everyStateFactParticipatesInEquality() throws
    {
        let base = try Self.editableState(endOffset: 0)
        let variants = try [
            DocumentSessionState.readable(base.snapshot),
            Self.editableState(generation: 4, endOffset: 0),
            Self.editableState(form: .heading, endOffset: 0),
            Self.editableState(endOffset: 1)
        ]

        #expect(variants.allSatisfy { $0 != base })

        let readable = DocumentSessionState.readable(base.snapshot)
        let revisedSnapshot = try Self.snapshot(revision: 9)
        let revisedReadable = DocumentSessionState.readable(revisedSnapshot)
        #expect(readable != revisedReadable)
    }

    @Test("reconstruction leaves the original value unchanged")
    func reconstructionLeavesOriginalValueUnchanged() throws
    {
        let original = try Self.editableState(endOffset: 0)
        let witness = original
        let changed = try Self.editableState(endOffset: 2)

        #expect(original == witness)
        #expect(original != changed)
        guard case let .editable(editable) = original
        else
        {
            Issue.record("original was not editable")
            return
        }
        #expect(editable.selection == (try Self.selection(endOffset: 0)))
    }
}
