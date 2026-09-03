import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockSplitTests
{
    @Test("invalid points and table-bearing documents refuse atomically")
    func invalidPointsAndTablesRefuseAtomically() throws
    {
        let source = try Self.document(blocks: [
            (2, Self.paragraph([SemanticRun(text: "e\u{301}😀\r\n")]))
        ])
        let original = source
        let requests = try [
            Self.request(at: 0, documentMarker: 9),
            Self.request(at: 0, revision: 9),
            Self.request(at: 0, blockMarker: 9),
            Self.request(at: 99),
            Self.request(at: 1),
            Self.request(at: 3),
            Self.request(at: 5)
        ]
        for request in requests
        {
            #expect(AppliedSemanticBlockSplit(
                try #require(request),
                in: source
            ) == nil)
            #expect(source == original)
        }

        let crossRun = try Self.document(blocks: [
            (2, Self.paragraph([
                SemanticRun(text: "e"),
                SemanticRun(text: "\u{301}")
            ]))
        ])
        let crossRunCandidate = try Self.request(at: 1)
        let crossRunRequest = try #require(crossRunCandidate)
        #expect(AppliedSemanticBlockSplit(
            crossRunRequest,
            in: crossRun
        ) == nil)

        let table = try DocumentSnapshotTests.tableBlock()
        let tableCases: [[(UInt8, SemanticBlock)]] = [
            [(2, table)],
            [(2, Self.paragraph([SemanticRun(text: "AB")])), (7, table)],
            [(7, table), (2, Self.paragraph([SemanticRun(text: "AB")]))]
        ]
        for blocks in tableCases
        {
            let mixed = try Self.document(blocks: blocks)
            let candidate = try Self.request(at: 0)
            let request = try #require(candidate)
            #expect(AppliedSemanticBlockSplit(request, in: mixed) == nil)
        }
    }

    @Test("success advances once and terminal revision refuses")
    func revisionCaretAndSourceContractsRemainExact() throws
    {
        let source = try Self.document(revision: 41, blocks: [
            (2, Self.paragraph([SemanticRun(text: "AB")]))
        ])
        let original = source
        let candidate = try Self.apply(
            at: 1,
            revision: 41,
            in: source
        )
        let result = try #require(candidate)

        #expect(source == original)
        #expect(result.document.revision == DocumentRevision(42))
        #expect(result.caret.point.documentID == source.documentID)
        #expect(result.caret.point.revision == DocumentRevision(42))
        #expect(result.caret.point.blockID == (try Self.blockID(3)))
        #expect(result.caret.point.utf16Offset.value == 0)
        #expect(result.caret.blockIndex == 1)
        let resolved = try #require(ResolvedDocumentPoint(
            result.caret.point,
            in: result.document
        ))
        #expect(result.caret == resolved)

        let terminal = try Self.document(
            revision: UInt64.max,
            blocks: [(2, Self.paragraph([]))]
        )
        #expect(try Self.apply(
            at: 0,
            revision: UInt64.max,
            in: terminal
        ) == nil)
    }
}
