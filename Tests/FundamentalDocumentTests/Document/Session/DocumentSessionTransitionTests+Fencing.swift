import Testing

@testable import FundamentalDocument

extension DocumentSessionTransitionTests
{
    @Test("each observation field independently fences a command")
    func observationFences() throws
    {
        let fixture = try SessionTestDocument()
        let mismatches = [
            try SessionTestDocument(marker: 9),
            try SessionTestDocument(revision: 7),
            try SessionTestDocument(generation: 2)
        ]
        for mismatch in mismatches
        {
            let commands: [DocumentSessionCommand] = [
                .edit(mismatch.observation,
                      try SessionTestEdit.insertion.edit(in: fixture)),
                .select(mismatch.observation, fixture.editable.selection)
            ]
            for command in commands
            {
                #expect(DocumentSessionTransition(command, in: fixture.state)
                    == .refused(.staleObservation))
            }
        }
    }

    @Test("a selection-only change invalidates an earlier observation")
    func staleAfterSelection() throws
    {
        let fixture = try SessionTestDocument()
        let next = try Self.editable(DocumentSessionTransition(
            .select(fixture.observation, fixture.selection(3, 1)),
            in: fixture.state
        ))
        let command = DocumentSessionCommand.edit(
            fixture.observation,
            try SessionTestEdit.insertion.edit(in: fixture)
        )
        #expect(next.snapshot.document.revision.value == 8)
        #expect(DocumentSessionTransition(command, in: .editable(next))
            == .refused(.staleObservation))
    }

    @Test("a matching observation cannot validate stale edit coordinates")
    func embeddedCoordinates() throws
    {
        let fixture = try SessionTestDocument()
        let mismatches = [
            try SessionTestDocument(revision: 7),
            try SessionTestDocument(marker: 9)
        ]
        for mismatch in mismatches
        {
            let command = DocumentSessionCommand.edit(
                fixture.observation,
                try SessionTestEdit.insertion.edit(in: mismatch)
            )
            #expect(DocumentSessionTransition(command, in: fixture.state)
                == .refused(.invalidCommand))
        }
    }
}
