@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
@MainActor
enum TerminalSweepFixture
{
    static func sources() throws
        -> [(name: String, source: ParagraphHyphens, widths: [Int])]
    {
        var results = try ComposerWitness.paragraphs().enumerated().map
        {
            index, paragraph in
            (
                name: "witness-\(index)", source: paragraph.collection,
                widths: [240, 280, 320, 360, 400]
            )
        }
        let additional = [
            (
                "Clear endings help readers keep a paragraph together "
                    + "without changing its words.",
                "en_US"
            ),
            (
                "Завершение абзаца должно сохранять целые слова "
                    + "и спокойный ритм чтения.",
                "ru_RU"
            )
        ]
        for (index, (text, language)) in additional.enumerated()
        {
            results.append((
                name: "additional-\(index)",
                source: try AutomaticFixture.collection(
                    ExplicitFixture.source(text, language: language),
                    language: language == "ru_RU" ? .russian : .english
                ),
                widths: [160, 240, 320]
            ))
        }
        return results
    }
}
