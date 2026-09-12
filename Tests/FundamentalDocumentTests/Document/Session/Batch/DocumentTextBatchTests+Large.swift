import Testing

@testable import FundamentalDocument

extension DocumentTextBatchTests
{
    @Test("many matches in one run remain one exact Unicode transaction")
    func manyMatches() throws
    {
        let count = 4_096
        let fixture = try SessionTestDocument(texts: [
            String(repeating: "A ", count: count)
        ])
        let values = (0 ..< count).reversed().map
        {
            (0, ($0 * 2) ..< ($0 * 2 + 1), "Б")
        }
        let batch = try Self.batch(values, in: fixture)
        let session = DocumentSession(state: fixture.state)
        session.submit(.replace(fixture.observation, batch))
        #expect(try Self.spelling(session) == [Array(
            String(repeating: "Б ", count: count).utf16
        )])
        #expect(session.history.undo.count == 1)
        #expect(session.document.revision.value == 9)
        #expect(session.state.snapshot.generation.value == 4)
        try Self.move(session, .undo)
        #expect(session.document.content == fixture.editable.snapshot
            .document.content)
    }

    @Test("a later unsupported prose replacement refuses earlier valid text")
    func proseLineEndingRefusal() throws
    {
        let fixture = try SessionTestDocument()
        let batch = try Self.batch([
            (0, 0 ..< 1, "X"), (1, 0 ..< 1, "Y\nZ")
        ], in: fixture)
        let session = DocumentSession(state: fixture.state)
        #expect(session.submit(.replace(fixture.observation, batch)) ==
            .refused(.invalidCommand))
        #expect(session.state == fixture.state)
        #expect(!session.canUndo)
    }

    @Test("read-only sessions refuse batch replacement")
    func readOnly() throws
    {
        let fixture = try SessionTestDocument()
        let batch = try Self.batch([(0, 0 ..< 1, "X")], in: fixture)
        let session = DocumentSession(
            state: .readable(fixture.editable.snapshot)
        )
        #expect(session.submit(.replace(fixture.observation, batch)) ==
            .refused(.readOnly))
        #expect(!session.canUndo)
    }
}
