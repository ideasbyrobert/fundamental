package enum OwnedWordOutcome: Sendable
{
    case sourceRefused
    case tokenAttributes
    case unsupportedLanguage(String)
    case protectedMarks([SourceHyphenationMark])
    case normalizationRefused(HyphenationFailure)
    case capitalizationRefused(OwnedCapitalization)
    case caseMappingRefused(OwnedCandidateFailure)
    case unsupportedAlphabet(PatternLanguage)
    case mappingRefused(
        LowercaseWordLookup, PatternResult, OwnedCandidateFailure
    )
    case candidates(OwnedWordCandidates)
}
