@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import FundamentalDocument
import Testing

@MainActor
@Suite
struct AutomaticScopeTests
{
    @Test
    func generatedStyleRetainsLinkAndLanguageAcrossEmptyRun() throws
    {
        let link = try #require(SemanticLinkDestination("https://example.com"))
        let us = try WordFixture.language("en_US")
        let value = try AutomaticFixture.collection(WordFixture.source([
            WordFixture.scoped(
                "extra", .linkAndLanguage(link: link, language: us),
                traits: [.strong, .underline]
            ),
            WordFixture.scoped(
                "", .language(WordFixture.language("ru_RU")),
                traits: [.inlineCode]
            ),
            WordFixture.run("ordinary")
        ]))
        #expect(value.inks[1].styleOrigin == WordRunFragment(
            runIndex: 0, paragraphRange: 4..<5, runRange: 4..<5
        ))
        let line = try AutomaticFixture.line(
            value, range: 0..<5,
            end: .automatic(value.selectAutomatic(1))
        )
        try AutomaticAssertions.compare(
            line, text: "extra‐",
            reference: ShapingReference.line([
                ("extra‐", [.strong, .underline])
            ])
        )
        #expect(line.display.body.slice.source.paragraph
            == value.source.paragraph)
        try AutomaticEvidence.write(
            "scoped-owner", collection: value, lines: [line]
        )
    }

    @Test
    func mixedSemanticLanguagesKeepTheirCandidateCoordinates() throws
    {
        let value = try AutomaticFixture.collection(WordFixture.source([
            WordFixture.scoped(
                "Extraordinary", .language(WordFixture.language("en_US"))
            ),
            WordFixture.run(" "),
            WordFixture.scoped(
                "Extraordinary", .language(WordFixture.language("en_GB"))
            ),
            WordFixture.run(" "),
            WordFixture.scoped(
                "Район", .language(WordFixture.language("ru_RU"))
            )
        ]))
        let offsets = [2, 5, 7, 9, 16, 24, 31]
        #expect(value.inks.map(\.candidate.sourceOffset) == offsets)
        let source = Array("Extraordinary Extraordinary Район".utf16)
        var lines: [HyphenatedShapedLine] = []
        for (index, offset) in offsets.enumerated()
        {
            let line = try AutomaticFixture.line(
                value, range: 0..<offset,
                end: .automatic(value.selectAutomatic(index))
            )
            let expected = String(decoding: source[..<offset], as: UTF16.self)
                + "‐"
            try AutomaticAssertions.compare(
                line, text: expected,
                reference: ShapingReference.line([(expected, [])])
            )
            lines.append(line)
        }
        try AutomaticEvidence.write(
            "mixed-languages", collection: value, lines: lines
        )
    }
}
