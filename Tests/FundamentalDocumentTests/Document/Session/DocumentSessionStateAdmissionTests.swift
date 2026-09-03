import Testing

@testable import FundamentalDocument

extension DocumentSessionStateTests
{
    @Test("every editable block form retains its exact selection")
    func everyEditableBlockFormRetainsExactSelection() throws
    {
        for form in EditableDocumentBlockForm.allCases
        {
            let state = try Self.editableState(
                form: form,
                endOffset: 2
            )
            guard case let .editable(editable) = state
            else
            {
                Issue.record("state was not editable")
                continue
            }

            #expect(editable.selection == (try Self.selection(endOffset: 2)))
            #expect(editable.snapshot == state.snapshot)
        }
    }

    @Test("both cases expose their complete readable snapshot")
    func bothCasesExposeCompleteReadableSnapshot() throws
    {
        let snapshot = try Self.snapshot()
        let selection = try Self.selection()
        let editable = try #require(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        ))
        let states: [DocumentSessionState] = [
            .readable(snapshot),
            .editable(editable)
        ]

        #expect(states.allSatisfy { $0.snapshot == snapshot })
    }
}
