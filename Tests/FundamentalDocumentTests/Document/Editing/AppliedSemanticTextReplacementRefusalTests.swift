import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextReplacementTests
{
    @Test("invalid scopes scalar bounds and tables refuse atomically")
    func invalidInputsRefuseAtomically() throws
    {
        let source = try Self.document(blocks: [
            (2, Self.paragraph([SemanticRun(text: "e\u{301}😀")]))
        ])
        let original = source
        let requests = try [
            Self.replacement(start: 0, end: 1, documentMarker: 9),
            Self.replacement(start: 0, end: 1, revision: 9),
            Self.replacement(start: 0, end: 1, blockMarker: 9),
            Self.replacement(start: 0, end: 5),
            Self.replacement(start: 3, end: 4)
        ]
        for request in requests
        {
            #expect(AppliedSemanticTextEdit(request, in: source) == nil)
            #expect(source == original)
        }

        let table = try DocumentSnapshotTests.tableBlock()
        let mixed = try Self.document(blocks: [
            (2, Self.paragraph([SemanticRun(text: "AB")])),
            (3, table)
        ])
        let originalMixed = mixed
        let mixedRequest = try Self.replacement(start: 0, end: 1)
        #expect(AppliedSemanticTextEdit(
            mixedRequest,
            in: mixed
        ) == nil)
        #expect(mixed == originalMixed)

        let tableDocument = try Self.document(blocks: [(2, table)])
        let originalTable = tableDocument
        let tableRequest = try Self.replacement(start: 0, end: 1)
        #expect(AppliedSemanticTextEdit(
            tableRequest,
            in: tableDocument
        ) == nil)
        #expect(tableDocument == originalTable)
    }

    @Test("terminal revision refuses atomically")
    func terminalRevisionRefusesAtomically() throws
    {
        let source = try Self.document(
            revision: UInt64.max,
            blocks: [(2, Self.paragraph([SemanticRun(text: "AB")]))]
        )
        let original = source
        let request = try Self.replacement(
            start: 0,
            end: 1,
            revision: UInt64.max
        )

        #expect(AppliedSemanticTextEdit(request, in: source) == nil)
        #expect(source == original)
    }
}
