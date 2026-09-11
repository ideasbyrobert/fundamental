import Foundation
import Testing

@testable import FundamentalParagraph

enum PatternFixture
{
    static func directory() throws -> URL
    {
        try BundledParagraphPatterns.directory
    }

    static func resource(_ locale: String) throws -> PatternResource
    {
        let entries = try BundledParagraphPatterns.resources(in: directory())
        #expect(entries.map(\.locale) == ["en_US", "en_GB", "ru_RU"])
        return try #require(entries.first { $0.locale == locale })
    }

    static func tokens(_ resource: PatternResource, suffix: String) throws
        -> [String]
    {
        let data = try resource.load(from: directory())
        let tokens = suffix == "pat" ? data.patterns.map(\.spelling)
            : data.exceptions.map(\.spelling)
        try PatternReference.verify(tokens, resource: resource, suffix: suffix)
        return tokens
    }

    static func dictionary(
        _ source: String, left: Int = 1, right: Int = 1
    ) throws -> PatternDictionary
    {
        try PatternDictionary(
            identity: "synthetic", data: PatternData(source),
            minima: PatternMinima(left: left, right: right)
        )
    }

    static let languages = ["en_US", "en_GB", "ru_RU"]

    static let words = [
        "hyphenation", "representation", "extraordinary", "paragraph",
        "deterministic", "editor", "computer", "typesetting", "typography",
        "university", "manuscript", "reciprocity", "association", "democracy",
        "democrat", "акация", "ствол", "отъезд", "кольцо", "район", "камин",
        "разыграть", "сестра", "юнеско", "камаз", "типография", "представление",
        "абзац", "программирование"
    ]
}
