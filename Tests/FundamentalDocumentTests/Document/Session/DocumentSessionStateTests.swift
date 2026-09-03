import Testing

@testable import FundamentalDocument

@Suite("Immutable document session state")
struct DocumentSessionStateTests
{
    @Test("every semantic table form remains readable only")
    func everySemanticTableFormRemainsReadableOnly() throws
    {
        for form in DocumentSnapshotTableForm.allCases
        {
            let block = try DocumentSnapshotTests.tableBlock(form)
            let snapshot = try Self.snapshot(block: block)
            let selection = try Self.selection()
            let state = DocumentSessionState.readable(snapshot)

            #expect(state.snapshot == snapshot)
            #expect(EditableDocumentSnapshot(
                snapshot: snapshot,
                selection: selection
            ) == nil)
            guard case .readable = state
            else
            {
                Issue.record("table state was not readable")
                continue
            }
        }
    }

    @Test("a table-free document may remain deliberately readable")
    func tableFreeDocumentMayRemainReadable() throws
    {
        let snapshot = try Self.snapshot()
        let state = DocumentSessionState.readable(snapshot)

        guard case let .readable(value) = state
        else
        {
            Issue.record("state was not readable")
            return
        }
        #expect(value == snapshot)
    }
}
