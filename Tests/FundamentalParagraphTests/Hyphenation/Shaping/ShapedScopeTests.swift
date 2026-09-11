@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import FundamentalDocument
import Testing

@MainActor
@Suite
struct ShapedScopeTests
{
    @Test
    func markerKeepsLinkAndLanguageAcrossEmptyRuns() throws
    {
        let link = try #require(SemanticLinkDestination("https://example.com"))
        let english = try WordFixture.language("en_GB")
        let value = ExplicitParagraphHyphens(try WordFixture.source([
            WordFixture.run("extra"),
            WordFixture.scoped("", .language(WordFixture.language("ru_RU"))),
            WordFixture.scoped(
                "\u{AD}", .linkAndLanguage(link: link, language: english),
                traits: [.strong, .underline]
            ),
            WordFixture.run(""),
            WordFixture.run("ordinary")
        ], language: "en_GB"))
        let line = try ShapingFixture.line(
            value, range: 0..<6, end: .opportunity(value.select(0))
        )
        try ShapingAssertions.compare(
            line, text: "extra‐",
            reference: ShapingReference.line([
                ("extra", []), ("‐", [.strong, .underline])
            ])
        )
        let ink = line.runs.flatMap(\.glyphs).flatMap(\.sources)
            .filter { $0.kind == .conditionalHyphen }
        #expect(ink.map(\.fragment.runIndex) == [2])
        #expect(line.display.slice.source.paragraph == value.source.paragraph)
        try ShapingEvidence.write("scoped-marker", lines: [line])
    }

    @Test
    func combiningSequenceCanCrossAnOriginalRunBoundary() throws
    {
        let value = ExplicitParagraphHyphens(try WordFixture.source([
            WordFixture.run("👩‍💻 раи"),
            WordFixture.run("\u{306}"),
            WordFixture.run("\u{AD}", traits: [.strong]),
            WordFixture.run("он")
        ], language: "ru_RU"))
        let selected = try ShapingFixture.line(
            value, range: 0..<11, end: .opportunity(value.select(1))
        )
        let whole = try ShapingFixture.line(value, range: 0..<13)
        try ShapingAssertions.compare(
            selected, text: "👩‍💻 раи\u{306}‐",
            reference: ShapingReference.line([
                ("👩‍💻 раи\u{306}", []), ("‐", [.strong])
            ])
        )
        try ShapingAssertions.compare(
            whole, text: "👩‍💻 раи\u{306}он",
            reference: ShapingReference.line([("👩‍💻 раи\u{306}он", [])])
        )
        #expect(whole.runs.contains
        {
            $0.font.postScript != "TimesNewRomanPSMT"
        })
        try ShapingEvidence.write(
            "combining-run-seam", lines: [selected, whole]
        )
    }
}
