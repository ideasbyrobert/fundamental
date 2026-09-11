@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import FundamentalDocument
import Testing

@MainActor
@Suite
struct AutomaticOwnershipTests
{
    @Test(arguments: NativeWordScopeTests.allowedTraits, ["left", "right"])
    func eachSideOfARunSeamKeepsItsOwnStyle(
        _ traits: Set<SemanticInlineTrait>, _ side: String
    ) throws
    {
        let left: Set<SemanticInlineTrait> = side == "left" ? traits : []
        let right: Set<SemanticInlineTrait> = side == "right" ? traits : []
        let value = try AutomaticFixture.collection(WordFixture.source([
            WordFixture.run("extra", traits: left),
            WordFixture.run("ordinary", traits: right)
        ]))
        #expect(value.inks.map(\.candidate.sourceOffset) == [2, 5, 7, 9])
        var lines: [HyphenatedShapedLine] = []
        for (index, offset) in [2, 5, 7, 9].enumerated()
        {
            let owner = offset <= 5 ? 0 : 1
            #expect(value.inks[index].styleOrigin.runIndex == owner)
            #expect(value.inks[index].character == (offset - 1)..<offset)
            let first = String("extra".prefix(min(offset, 5)))
            let second = String("ordinary".prefix(max(0, offset - 5)))
            let parts = [
                (first, left), (second, right),
                ("‐", owner == 0 ? left : right)
            ]
            let line = try AutomaticFixture.line(
                value, range: 0..<offset,
                end: .automatic(value.selectAutomatic(index))
            )
            try AutomaticAssertions.compare(
                line, text: first + second + "‐",
                reference: ShapingReference.line(parts)
            )
            lines.append(line)
        }
        let names = traits.map(\.rawValue).sorted().joined(separator: "-")
        try AutomaticEvidence.write(
            "traits-" + side + "-" + names, collection: value, lines: lines
        )
    }

    @Test
    func baseRunOwnsInkWhenCombiningMarkHasAnotherStyle() throws
    {
        let value = try AutomaticFixture.collection(WordFixture.source([
            WordFixture.run("👩‍💻 раи", traits: [.strong]),
            WordFixture.run("\u{306}", traits: [.emphasis]),
            WordFixture.run("он")
        ], language: "ru_RU"), language: .russian)
        let ink = try #require(value.inks.first)
        #expect(ink.candidate.sourceOffset == 10)
        #expect(ink.character == 8..<10)
        #expect(ink.context.map(\.paragraphRange) == [8..<9, 9..<10])
        #expect(ink.styleOrigin.runIndex == 0)
        let line = try AutomaticFixture.line(
            value, range: 0..<10,
            end: .automatic(value.selectAutomatic(0))
        )
        try AutomaticAssertions.compare(
            line, text: "👩‍💻 раи\u{306}‐",
            reference: ShapingReference.line([
                ("👩‍💻 раи", [.strong]), ("\u{306}", [.emphasis]), ("‐", [.strong])
            ])
        )
        try AutomaticEvidence.write(
            "combining-style", collection: value, lines: [line]
        )
    }
}
