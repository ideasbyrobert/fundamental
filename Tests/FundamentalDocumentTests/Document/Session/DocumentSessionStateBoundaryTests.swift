import Testing

@testable import FundamentalDocument

extension DocumentSessionStateTests
{
    @Test("terminal generation and unrelated revision remain exact")
    func terminalGenerationAndUnrelatedRevisionRemainExact() throws
    {
        let state = try Self.editableState(
            generation: UInt64.max,
            revision: 41,
            endOffset: 2
        )

        #expect(state.snapshot.generation == SnapshotGeneration(UInt64.max))
        #expect(state.snapshot.document.revision == DocumentRevision(41))
        guard case let .editable(editable) = state
        else
        {
            Issue.record("terminal state was not editable")
            return
        }
        #expect(editable.selection == (try Self.selection(
            revision: 41,
            endOffset: 2
        )))
    }

    @Test("the cases are exhaustive and the state is Sendable")
    func casesAreExhaustiveAndStateIsSendable() throws
    {
        let states = try [
            DocumentSessionState.readable(Self.snapshot()),
            Self.editableState()
        ]
        let names = states.map
        {
            switch $0
            {
            case .readable:
                "readable"
            case .editable:
                "editable"
            }
        }

        #expect(names == ["readable", "editable"])
        Self.requireSendable(DocumentSessionState.self)
    }
}
