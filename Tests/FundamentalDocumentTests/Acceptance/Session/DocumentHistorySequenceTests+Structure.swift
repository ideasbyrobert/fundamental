import Testing

@testable import FundamentalDocument

extension DocumentHistorySequenceTests
{
    @Test(arguments: ["", "ABCD", "e\u{301}😀"])
    func splitMergeHistoryRestoresExactBlockAndRunBoundaries(
        _ text: String
    ) throws
    {
        let fixture = try SessionTestDocument(texts: [text])
        let driver = SessionHistoryTestDriver(fixture)
        let original = fixture.editable.snapshot.document.content
        let offset = text.isEmpty ? 0 : 2
        let continuation = FundamentalBlockID(SessionTestDocument.identity(9))
        let split = try #require(SemanticBlockSplit(
            point: driver.point(offset),
            continuationBlockID: continuation
        ))
        let splitState = try driver.edit(.split(split))
        let splitContent = splitState.snapshot.document.content
        #expect(splitContent.blocks.map(\.blockID) == [
            original.firstBlock.blockID, continuation
        ])
        let units = Array(text.utf16)
        let expectedSplit: [[[UInt16]]] = text.isEmpty ? [[], [[]]] : [
            [Array(units.prefix(offset))], [Array(units.dropFirst(offset))]
        ]
        #expect(try runUnits(splitContent) == expectedSplit)
        let document = splitState.snapshot.document
        let merge = try #require(SemanticBlockMerge(
            documentID: document.documentID,
            revision: document.revision,
            leadingBlockID: original.firstBlock.blockID,
            trailingBlockID: continuation
        ))
        let merged = try driver.edit(.merge(merge))
        let expectedMerge = [expectedSplit.flatMap { $0 }]
        #expect(try runUnits(merged.snapshot.document.content) == expectedMerge)
        let undoMerge = try driver.move(.undo)
        #expect(undoMerge.snapshot.document.content == splitContent)
        #expect(try runUnits(undoMerge.snapshot.document.content) ==
            expectedSplit)
        let undoSplit = try driver.move(.undo)
        #expect(undoSplit.snapshot.document.content == original)
        #expect(try runUnits(undoSplit.snapshot.document.content) == [[units]])
        let redoSplit = try driver.move(.redo)
        #expect(redoSplit.snapshot.document.content == splitContent)
        let redoMerge = try driver.move(.redo)
        #expect(try runUnits(redoMerge.snapshot.document.content) ==
            expectedMerge)
        #expect(redoMerge.snapshot.document.revision.value == 14)
        #expect(redoMerge.snapshot.generation.value == 9)
        #expect(try runUnits(original) == [[units]])
    }
}
