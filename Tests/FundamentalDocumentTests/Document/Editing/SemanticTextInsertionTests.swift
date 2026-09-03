import Testing

@testable import FundamentalDocument

extension SemanticTextEditTests
{
    @Test("direct insertion preserves its required facts")
    func directInsertionPreservesRequiredFacts() throws
    {
        let point = try Self.point(offset: 5)
        let payload = try Self.insertion("Direct")
        let insertion = SemanticTextInsertion(
            point: point,
            insertion: payload
        )

        #expect(insertion.point == point)
        #expect(insertion.insertion == payload)
    }

    @Test("scoped insertion preserves its required facts")
    func scopedInsertionPreservesRequiredFacts() throws
    {
        let point = try Self.point(offset: 7)
        let payload = try Self.scopedInsertion("Scoped")
        let insertion = SemanticTextInsertion(
            point: point,
            insertion: payload
        )

        #expect(insertion.point == point)
        #expect(insertion.insertion == payload)
    }
}
