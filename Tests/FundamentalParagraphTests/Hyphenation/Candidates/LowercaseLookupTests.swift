@testable import FundamentalParagraph
import Foundation
import Testing

@Suite
struct LowercaseLookupTests
{
    @Test(arguments: [
        "Extraordinary", "Район", "Раи\u{306}он", "İstanbul", "A\u{30A}land",
        "CAFÉ", "Программирование", "ß", "👩‍💻", "각"
    ])
    func coordinatesAgreeWithIndependentPrefixLengths(_ word: String) throws
    {
        let prefix = "👩‍💻 "
        let lookup = try OwnedFixture.lookup(word, prefix: prefix)
        var rows: [[Int]] = [[prefix.utf16.count, 0]]
        var sourcePrefix = ""
        for character in word
        {
            sourcePrefix.append(character)
            let transformed = sourcePrefix.precomposedStringWithCanonicalMapping
                .lowercased(with: Locale(identifier: "en_US_POSIX"))
                .precomposedStringWithCanonicalMapping
            rows.append([
                prefix.utf16.count + sourcePrefix.utf16.count,
                transformed.utf16.count
            ])
        }
        #expect(lookup.boundaries.map { [$0.source, $0.lookup] } == rows)
        #expect(lookup.normalized.sourceUTF16 == Array(word.utf16))
        for row in rows
        {
            #expect(try lookup.sourceOffset(at: row[1]) == row[0])
        }
        let name = OwnedEvidence.spellingName(word)
        try PatternEvidence.write(
            name, group: "case-coordinates", record: [
                "lookup": OwnedEvidence.describe(lookup), "prefixOracle": rows
            ]
        )
    }

    @Test
    func contextualCaseConversionCannotInventPerCharacterCoordinates() throws
    {
        let source = "ΟΣ"
        let locale = Locale(identifier: "en_US_POSIX")
        let whole = source.lowercased(with: locale)
        let separate = source.map
        {
            String($0).lowercased(with: locale)
        }.joined()
        try PatternEvidence.write(
            "sigma", group: "case-coordinates", record: [
                "sourceUTF16": Array(source.utf16),
                "parameterlessUTF16": Array(source.lowercased().utf16),
                "caseLocale": locale.identifier,
                "wholeUTF16": Array(whole.utf16),
                "separateUTF16": Array(separate.utf16)
            ]
        )
        #expect(!whole.utf16.elementsEqual(separate.utf16))
        #expect(Array(whole.utf16) == [959, 962])
        #expect(throws: OwnedCandidateFailure.contextualCaseMapping)
        {
            try OwnedFixture.lookup(source)
        }
    }
}
