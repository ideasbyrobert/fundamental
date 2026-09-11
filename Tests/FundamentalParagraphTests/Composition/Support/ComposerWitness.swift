@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import AppKit
import Testing

@MainActor
enum ComposerWitness
{
    static func paragraphs() throws -> [ParagraphComposition]
    {
        let texts = [
            (
                "A paragraph is more than a sequence of short lines. "
                    + "Extraordinary words and carefully chosen breaks "
                    + "give the whole passage a steadier rhythm.",
                "en_US"
            ),
            (
                "Хорошая типографика сохраняет смысл и ритм текста. "
                    + "Переносы слов помогают выстроить ровный край абзаца "
                    + "и сохранить спокойные расстояния между словами.",
                "ru_RU"
            )
        ]
        return try texts.map
        {
            text, language in
            try ParagraphFixture.compose(
                AutomaticFixture.collection(
                    ExplicitFixture.source(text, language: language),
                    language: language == "ru_RU" ? .russian : .english
                ),
                width: 320
            )
        }
    }

}
