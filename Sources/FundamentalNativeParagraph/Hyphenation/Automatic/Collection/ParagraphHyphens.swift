import FundamentalParagraph
package struct ParagraphHyphens: Sendable
{
    package static let inkPolicyVersion = 1
    let identity = AutomaticSelectionOwner()
    package let automatic: ParagraphOwnedCandidates
    package let explicit: ExplicitParagraphHyphens
    package let inks: [AutomaticHyphenInk]

    package var source: ParagraphWordSource
    {
        automatic.words.source
    }

    package init(
        _ words: NativeParagraphWords, catalog: OwnedPatternCatalog,
        match: (PatternDictionary, String) throws -> PatternResult =
        {
            try $0.hyphenate($1)
        }
    ) throws
    {
        let automatic = try ParagraphOwnedCandidates(
            words, catalog: catalog, match: match
        )
        var inks: [AutomaticHyphenInk] = []
        for (wordIndex, record) in automatic.records.enumerated()
        {
            if case let .candidates(value) = record.outcome
            {
                for (candidateIndex, candidate) in value.candidates.enumerated()
                {
                    inks.append(try AutomaticHyphenInk(
                        wordIndex: wordIndex, candidateIndex: candidateIndex,
                        candidate: candidate,
                        word: record.word.resolution.range, source: words.source
                    ))
                }
            }
        }
        self.automatic = automatic
        explicit = ExplicitParagraphHyphens(words.source)
        self.inks = inks
    }
}
