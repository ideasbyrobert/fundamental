import Foundation
import FundamentalWrapping

package struct NormalizedWordLookup: Equatable, Sendable
{
    package let sourceRange: Range<Int>
    package let sourceUTF16: [UInt16]
    package let text: String
    package let boundaries: [HyphenationBoundary]

    package init(
        source: WrappingSource, range: Range<Int>
    ) throws(HyphenationFailure)
    {
        guard !range.isEmpty,
              source.isBoundary(range.lowerBound),
              source.isBoundary(range.upperBound)
        else
        {
            throw .invalidRange(range)
        }
        let units = Array(source.utf16[range])
        let word = String(decoding: units, as: UTF16.self)
        let whole = word.precomposedStringWithCanonicalMapping
        let first = source.boundaryIndex(atOrBefore: range.lowerBound)
        let last = source.boundaryIndex(atOrBefore: range.upperBound)
        var normalized = ""
        var offset = 0
        var pairs = [HyphenationBoundary(source: range.lowerBound, lookup: 0)]
        for index in first..<last
        {
            let lower = source.graphemeBoundaries[index]
            let upper = source.graphemeBoundaries[index + 1]
            let character = String(
                decoding: source.utf16[lower..<upper], as: UTF16.self
            )
            let part = character.precomposedStringWithCanonicalMapping
            guard !part.isEmpty
            else
            {
                throw .incompatibleNormalization
            }
            normalized.append(contentsOf: part)
            offset += part.utf16.count
            pairs.append(HyphenationBoundary(source: upper, lookup: offset))
        }
        guard normalized.utf16.elementsEqual(whole.utf16)
        else
        {
            throw .incompatibleNormalization
        }
        sourceRange = range
        sourceUTF16 = units
        text = whole
        boundaries = pairs
    }
}
