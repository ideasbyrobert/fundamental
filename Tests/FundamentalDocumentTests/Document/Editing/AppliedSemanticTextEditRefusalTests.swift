import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextEditTests
{
    @Test("invalid scopes boundaries and tables refuse atomically")
    func invalidScopesBoundariesAndTablesRefuseAtomically() throws
    {
        let source = try Self.document(blocks: [
            (2, Self.paragraph([SemanticRun(text: "e\u{301}😀")]))
        ])
        let original = source
        let requests = try [
            Self.edit(at: 0, documentMarker: 9),
            Self.edit(at: 0, revision: 9),
            Self.edit(at: 0, blockMarker: 9),
            Self.edit(at: 7),
            Self.edit(at: 1),
            Self.edit(at: 3)
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
        let mixedRequest = try Self.edit(at: 1)
        #expect(AppliedSemanticTextEdit(
            mixedRequest,
            in: mixed
        ) == nil)
        #expect(mixed == originalMixed)
    }

    @Test("terminal revision refuses atomically")
    func terminalRevisionRefusesAtomically() throws
    {
        let source = try Self.document(
            revision: UInt64.max,
            blocks: [(2, Self.paragraph([SemanticRun(text: "AB")]))]
        )
        let original = source
        let request = try Self.edit(
            at: 1,
            revision: UInt64.max
        )

        #expect(AppliedSemanticTextEdit(request, in: source) == nil)
        #expect(source == original)
    }
}
