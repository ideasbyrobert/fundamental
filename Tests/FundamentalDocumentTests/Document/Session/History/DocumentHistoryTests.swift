import Testing

@testable import FundamentalDocument

@Suite("Bounded canonical history values")
struct DocumentHistoryTests
{
    @Test
    func emptyHistoryHasNoInventedTransaction()
    {
        let history = DocumentHistory()
        #expect(history.undo.isEmpty)
        #expect(history.redo.isEmpty)
        #expect(history.retainedUTF16Units == 0)
        #expect(DocumentHistory(moving: .undo, in: history) == nil)
        #expect(DocumentHistory(moving: .redo, in: history) == nil)
    }
}
