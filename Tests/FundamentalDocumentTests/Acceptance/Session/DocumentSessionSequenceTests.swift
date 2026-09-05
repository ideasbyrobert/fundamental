import Testing

@testable import FundamentalDocument

@Suite("Document session event sequence", .serialized)
@MainActor
struct DocumentSessionSequenceTests
{
    @Test
    func selectionEditReplayAndFreshEdit() throws
    {
        let fixture = try SessionTestDocument(texts: ["ABCD"])
        let session = DocumentSession(state: fixture.state)
        let initial = session.state
        let firstObservation = session.observation
        let firstEdit = try SessionTestEdit.inserted("X", at: fixture.point(1))
        let selected = try applied(session.submit(.select(
            firstObservation,
            try fixture.selection(3, 1)
        )))
        #expect(selected.snapshot.generation.value == 4)
        #expect(selected.snapshot.document.revision.value == 8)
        #expect(selected.selection == (try fixture.selection(3, 1)))
        #expect(session.submit(.edit(firstObservation, firstEdit)) ==
            .refused(.staleObservation))
        #expect(session.state == .editable(selected))

        let secondObservation = session.observation
        let edited = try applied(session.submit(.edit(
            secondObservation,
            firstEdit
        )))
        try expect(edited, spelling: "AXBCD", revision: 9, generation: 5)
        #expect(edited.selection.range.start.utf16Offset.value == 2)
        #expect(edited.selection.isCollapsed)
        #expect(session.submit(.edit(secondObservation, firstEdit)) ==
            .refused(.staleObservation))
        let thirdObservation = session.observation
        #expect(session.submit(.select(thirdObservation, edited.selection)) ==
            .unchanged)
        #expect(session.observation == thirdObservation)

        let nextEdit = try SessionTestEdit.inserted(
            "Y",
            at: edited.selection.range.start
        )
        let final = try applied(session.submit(.edit(
            thirdObservation,
            nextEdit
        )))
        try expect(final, spelling: "AXYBCD", revision: 10, generation: 6)
        #expect(final.selection.range.start.utf16Offset.value == 3)
        try expect(edited, spelling: "AXBCD", revision: 9, generation: 5)
        try expect(selected, spelling: "ABCD", revision: 8, generation: 4)
        #expect(initial == fixture.state)
        try expect(fixture.editable, spelling: "ABCD", revision: 8,
                   generation: 3)
    }
}
