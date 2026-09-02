import Testing

@testable import FundamentalDocument

extension ResolvedPostEditCaretTests
{
    @Test("decomposed and control interiors honor logical affinity")
    func decomposedAndControlInteriorsHonorAffinity() throws
    {
        for text in ["e\u{301}", "\r\n", "\u{1100}\u{1161}"]
        {
            let offsets = try Self.resolvedOffsets(
                texts: [text],
                candidate: 1
            )
            #expect(offsets == [0, 2])
        }
    }

    @Test("a Devanagari interior honors logical affinity")
    func devanagariInteriorHonorsAffinity() throws
    {
        let offsets = try Self.resolvedOffsets(
            texts: ["कि"],
            candidate: 1
        )

        #expect(offsets == [0, 2])
    }

    @Test("a variation selector interior honors logical affinity")
    func variationSelectorInteriorHonorsAffinity() throws
    {
        let offsets = try Self.resolvedOffsets(
            texts: ["\u{2708}\u{FE0F}"],
            candidate: 1
        )

        #expect(offsets == [0, 2])
    }

    @Test("a ZWJ interior honors logical affinity")
    func zwjInteriorHonorsAffinity() throws
    {
        let offsets = try Self.resolvedOffsets(
            texts: ["👨‍👩‍👧‍👦"],
            candidate: 9
        )

        #expect(offsets == [0, 11])
    }

    @Test("a surviving flag resolves away from its scalar seam")
    func survivingFlagResolvesAwayFromScalarSeam() throws
    {
        let survivor = try Self.resolvedOffsets(
            texts: ["\u{1F1E6}\u{1F1FA}"],
            candidate: 2
        )
        let contextual = try Self.resolvedOffsets(
            texts: ["\u{1F1E6}\u{1F1F2}\u{1F1FA}"],
            candidate: 2
        )
        let exact = try Self.resolvedOffsets(
            texts: ["\u{1F1E6}\u{1F1F2}\u{1F1FA}"],
            candidate: 4
        )

        #expect(survivor == [0, 4])
        #expect(contextual == [0, 4])
        #expect(exact == [4, 4])
    }

    @Test("an emoji modifier interior honors logical affinity")
    func emojiModifierInteriorHonorsAffinity() throws
    {
        let offsets = try Self.resolvedOffsets(
            texts: ["👍🏽"],
            candidate: 2
        )

        #expect(offsets == [0, 4])
    }
}
