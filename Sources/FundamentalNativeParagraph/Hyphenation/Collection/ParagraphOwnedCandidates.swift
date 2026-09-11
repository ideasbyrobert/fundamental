import FundamentalParagraph

package struct ParagraphOwnedCandidates: Sendable
{
    package static let policyVersion = 1
    package let words: NativeParagraphWords
    package let records: [OwnedWordRecord]

    package init(
        _ words: NativeParagraphWords, catalog: OwnedPatternCatalog,
        match: (PatternDictionary, String) throws -> PatternResult =
        {
            try $0.hyphenate($1)
        }
    ) throws
    {
        let marks = ParagraphHyphenationMarks(words.source.source)
        func evaluate(_ word: NativeWordObservation) throws -> OwnedWordOutcome
        {
            guard case let .resolved(scope) = word.resolution
            else
            {
                return .sourceRefused
            }
            guard word.flags == 0
            else
            {
                return .tokenAttributes
            }
            guard let language = PatternLanguage(rawValue: scope.language.value)
            else
            {
                return .unsupportedLanguage(scope.language.value)
            }
            let protected = marks.touching(scope.range)
            guard protected.isEmpty
            else
            {
                return .protectedMarks(protected)
            }
            let normalized: NormalizedWordLookup
            do
            {
                normalized = try NormalizedWordLookup(
                    source: words.source.source, range: scope.range
                )
            }
            catch
            {
                return .normalizationRefused(error)
            }
            let capitalization = OwnedCapitalization(normalized.text)
            guard capitalization.permitsLookup
            else
            {
                return .capitalizationRefused(capitalization)
            }
            let lookup: LowercaseWordLookup
            do
            {
                lookup = try LowercaseWordLookup(normalized)
            }
            catch
            {
                return .caseMappingRefused(error)
            }
            guard language.accepts(lookup.text)
            else
            {
                return .unsupportedAlphabet(language)
            }
            let dictionary = try catalog.dictionary(language)
            let result = try match(dictionary, lookup.text)
            do
            {
                return .candidates(try OwnedWordCandidates(
                    lookup: lookup, result: result,
                    identity: dictionary.identity
                ))
            }
            catch
            {
                return .mappingRefused(lookup, result, error)
            }
        }
        self.words = words
        records = try words.observations.map
        {
            OwnedWordRecord(word: $0, outcome: try evaluate($0))
        }
    }
}
