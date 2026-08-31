import Testing

@testable import FundamentalDocument

@Suite("A document selection")
struct DocumentSelectionTests
{
    @Test("construction preserves the exact directed range")
    func constructionPreservesDirectedRange() throws
    {
        let start = try DocumentRangeTests.point(
            blockMarker: 8,
            offset: 13
        )
        let end = try DocumentRangeTests.point(
            blockMarker: 3,
            offset: 2
        )
        let range = try #require(DocumentRange(start: start, end: end))
        let selection = DocumentSelection(range: range)

        #expect(selection.range == range)
        #expect(selection.range.start == start)
        #expect(selection.range.end == end)
    }

    @Test("caret construction preserves one collapsed point")
    func caretConstructionPreservesPoint() throws
    {
        let point = try DocumentRangeTests.point(offset: 5)
        let selection = DocumentSelection.caret(at: point)

        #expect(selection.range.start == point)
        #expect(selection.range.end == point)
        #expect(selection.isCollapsed)
    }

    @Test("extended selection remains noncollapsed")
    func extendedSelectionRemainsNoncollapsed() throws
    {
        let range = try #require(
            DocumentRange(
                start: DocumentRangeTests.point(offset: 3),
                end: DocumentRangeTests.point(offset: 8)
            )
        )
        let selection = DocumentSelection(range: range)

        #expect(!selection.isCollapsed)
        #expect(selection.range == range)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let point = try DocumentRangeTests.point(offset: 2)
        let original = DocumentSelection.caret(at: point)
        let replacementRange = try #require(
            DocumentRange(
                start: point,
                end: DocumentRangeTests.point(offset: 7)
            )
        )
        let replacement = DocumentSelection(range: replacementRange)

        #expect(original.isCollapsed)
        #expect(original.range == DocumentRange.caret(at: point))
        #expect(!replacement.isCollapsed)
    }
}
