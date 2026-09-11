import FundamentalParagraph
package struct AutomaticHyphenInk: Equatable, Sendable
{
    package let wordIndex: Int
    package let candidateIndex: Int
    package let candidate: HyphenationCandidate
    package let character: Range<Int>
    package let context: [WordRunFragment]
    package let styleOrigin: WordRunFragment

    package var sourceRange: Range<Int>
    {
        candidate.sourceOffset..<candidate.sourceOffset
    }

    package init(
        wordIndex: Int, candidateIndex: Int,
        candidate: HyphenationCandidate, word: Range<Int>,
        source: ParagraphWordSource
    ) throws
    {
        let text = source.source
        let offset = candidate.sourceOffset
        let index = text.boundaryIndex(atOrBefore: offset)
        guard index > 0, text.graphemeBoundaries[index] == offset,
              offset < word.upperBound, candidate.hyphenScalar == 0x2010
        else
        {
            throw AutomaticInkFailure.invalidOwner
        }
        let range = text.graphemeBoundaries[index - 1]..<offset
        let context = source.fragments(in: range).fragments
        guard range.lowerBound >= word.lowerBound,
              let first = context.first,
              first.paragraphRange.lowerBound == range.lowerBound,
              context.reduce(0, { $0 + $1.paragraphRange.count }) == range.count
        else
        {
            throw AutomaticInkFailure.invalidOwner
        }
        self.wordIndex = wordIndex
        self.candidateIndex = candidateIndex
        self.candidate = candidate
        character = range
        self.context = context
        styleOrigin = first
    }
}
