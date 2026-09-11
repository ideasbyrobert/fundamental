import AppKit
import FundamentalNativeParagraph
import FundamentalParagraph
import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@MainActor
struct LayoutProseLanguageTests
{
    @Test func exactLanguageScopesOverrideTheExplicitDefault() throws
    {
        for identifier in ["ru_RU", "ru-RU", "ru"]
        {
            let language = try #require(SemanticLanguageIdentifier(identifier))
            let runs: [SemanticRun] = [.scoped(.init(
                text: "представление", traits: [], scopes: .language(language)
            ))]
            let result = try NativeProseComposition(
                LayoutProseFixture.prose(runs), width: 80,
                font: .systemFont(ofSize: 18),
                language: .russian, defaultLanguage: "en_US"
            ).paragraph
            let records = result.collection.automatic.records
            let record = try #require(records.first)
            #expect(records.count == 1)
            #expect(result.collection.source.paragraph.runs == runs)
            if identifier == "ru_RU"
            {
                guard case let .candidates(value) = record.outcome
                else
                {
                    Issue.record("Expected Russian candidates")
                    continue
                }
                #expect(!value.candidates.isEmpty)
            }
            else
            {
                guard case let .unsupportedLanguage(value) = record.outcome
                else
                {
                    Issue.record("Expected exact unsupported language")
                    continue
                }
                #expect(value == identifier)
            }
            try LayoutProseCapture.write(result, name: identifier)
        }
    }

    @Test func defaultsSelectDifferentOwnedDictionaries() throws
    {
        let prose = LayoutProseFixture.prose([
            LayoutFixture.direct("extraordinary")
        ])
        for (language, expected) in [
            ("en_US", [2, 5, 7, 9]), ("en_GB", [2, 10])
        ]
        {
            let result = try NativeProseComposition(
                prose, width: 80, font: .systemFont(ofSize: 18),
                language: .english, defaultLanguage: language
            ).paragraph
            #expect(result.collection.inks.map(\.candidate.sourceOffset)
                == expected)
            #expect(result.collection.source.paragraph == prose.paragraph)
            try LayoutProseCapture.write(result, name: language)
        }
    }
}
