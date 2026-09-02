import Testing

@testable import FundamentalDocument

@Suite("A resolved post-edit caret")
struct ResolvedPostEditCaretTests
{
    @Test("exact boundaries remain exact under either affinity")
    func exactBoundariesRemainExact() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph(["A😀B"]))
        ])

        for offset in [0, 1, 3, 4]
        {
            let candidate = try Self.point(offset: offset)
            for affinity in Self.affinities
            {
                let caret = try #require(ResolvedPostEditCaret(
                    candidate: candidate,
                    affinity: affinity,
                    in: document
                ))
                #expect(caret.resolvedPoint.point == candidate)
            }
        }
    }

    @Test("the result is an ordinary resolved document point")
    func resultIsAnOrdinaryResolvedPoint() throws
    {
        let document = try Self.document(
            documentMarker: 7,
            revision: 19,
            blocks: [
                (3, Self.paragraph(["Lead"])),
                (9, Self.paragraph(["e\u{301}"]))
            ]
        )
        let candidate = try Self.point(
            documentMarker: 7,
            revision: 19,
            blockMarker: 9,
            offset: 1
        )
        let expectedPoint = try Self.point(
            documentMarker: 7,
            revision: 19,
            blockMarker: 9,
            offset: 0
        )
        let expected = try #require(ResolvedDocumentPoint(
            expectedPoint,
            in: document
        ))
        let caret = try #require(ResolvedPostEditCaret(
            candidate: candidate,
            affinity: .preceding,
            in: document
        ))

        #expect(caret.resolvedPoint == expected)
        #expect(caret.resolvedPoint.blockIndex == 1)
    }

    @Test("a Character spanning runs resolves as one value")
    func characterSpanningRunsResolvesAsOneValue() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph(["A", "e", "\u{301}", "B"]))
        ])
        let original = document
        let offsets = try Self.resolvedOffsets(
            candidate: 2,
            in: document
        )

        #expect(offsets == [1, 3])
        #expect(document == original)
    }
}
