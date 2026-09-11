import FundamentalParagraph

extension ParagraphOwnedCandidates
{
    package func matching(_ query: Range<Int>) throws -> [OwnedWordRecord]
    {
        let ranges = Set(try words.matching(query).map(\.resolution.range))
        return records.filter { ranges.contains($0.word.resolution.range) }
    }
}
