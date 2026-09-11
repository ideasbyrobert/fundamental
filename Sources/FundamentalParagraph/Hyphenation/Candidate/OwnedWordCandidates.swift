package struct OwnedWordCandidates: Sendable
{
    package let lookup: LowercaseWordLookup
    package let result: PatternResult
    package let candidates: [HyphenationCandidate]

    package init(
        lookup: LowercaseWordLookup, result: PatternResult,
        identity: String
    ) throws(OwnedCandidateFailure)
    {
        guard result.identity == identity
        else
        {
            throw .changedIdentity
        }
        guard result.word.utf16.elementsEqual(lookup.text.utf16)
        else
        {
            throw .changedSpelling
        }
        var previous = 0
        var candidates: [HyphenationCandidate] = []
        for boundary in result.boundaries
        {
            guard boundary > previous, boundary < lookup.text.utf16.count
            else
            {
                throw .invalidBoundary(boundary)
            }
            let source = try lookup.sourceOffset(at: boundary)
            guard source > lookup.normalized.sourceRange.lowerBound,
                  source < lookup.normalized.sourceRange.upperBound
            else
            {
                throw .invalidBoundary(boundary)
            }
            candidates.append(.init(
                sourceOffset: source, lookupOffset: boundary,
                hyphenScalar: 0x2010
            ))
            previous = boundary
        }
        self.lookup = lookup
        self.result = result
        self.candidates = candidates
    }
}
