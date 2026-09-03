import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockMergeTests
{
    @Test("success advances once while terminal revision refuses")
    func successAdvancesOnceWhileTerminalRevisionRefuses() throws
    {
        let block = Self.paragraph([SemanticRun(text: "A")])
        let source = try Self.document(
            revision: 41,
            blocks: [(2, block), (3, block)]
        )
        let original = source
        let candidate = try Self.apply(revision: 41, in: source)
        let result = try #require(candidate)

        #expect(source == original)
        #expect(result.document.revision == DocumentRevision(42))
        #expect(result.document.documentID == source.documentID)
        #expect(result.caret.point.revision == DocumentRevision(42))

        let terminal = try Self.document(
            revision: UInt64.max,
            blocks: [(2, block), (3, block)]
        )
        let originalTerminal = terminal
        #expect(try Self.apply(
            revision: UInt64.max,
            in: terminal
        ) == nil)
        #expect(terminal == originalTerminal)
    }
}
