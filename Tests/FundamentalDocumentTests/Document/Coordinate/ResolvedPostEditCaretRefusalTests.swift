import Testing

@testable import FundamentalDocument

extension ResolvedPostEditCaretTests
{
    @Test("invalid document and block scopes are refused")
    func invalidDocumentAndBlockScopesAreRefused() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph(["A"]))
        ])
        let foreign = try Self.point(documentMarker: 9, offset: 0)
        let stale = try Self.point(revision: 7, offset: 0)
        let missing = try Self.point(blockMarker: 9, offset: 0)

        for candidate in [foreign, stale, missing]
        {
            for affinity in Self.affinities
            {
                #expect(ResolvedPostEditCaret(
                    candidate: candidate,
                    affinity: affinity,
                    in: document
                ) == nil)
            }
        }

        let tableDocument = try Self.document(blocks: [
            (2, .table(try SemanticBlockTests.emptyTableRecord()))
        ])
        let tableCandidate = try Self.point(offset: 0)
        for affinity in Self.affinities
        {
            #expect(ResolvedPostEditCaret(
                candidate: tableCandidate,
                affinity: affinity,
                in: tableDocument
            ) == nil)
        }
    }

    @Test("out-of-range and surrogate-interior offsets are refused")
    func invalidOffsetsAreRefused() throws
    {
        let shortDocument = try Self.document(blocks: [
            (2, Self.paragraph(["A"]))
        ])
        let outOfRange = try Self.point(offset: 2)
        let emojiDocument = try Self.document(blocks: [
            (2, Self.paragraph(["😀"]))
        ])
        let surrogateInterior = try Self.point(offset: 1)

        for affinity in Self.affinities
        {
            #expect(ResolvedPostEditCaret(
                candidate: outOfRange,
                affinity: affinity,
                in: shortDocument
            ) == nil)
            #expect(ResolvedPostEditCaret(
                candidate: surrogateInterior,
                affinity: affinity,
                in: emojiDocument
            ) == nil)
        }
    }
}
