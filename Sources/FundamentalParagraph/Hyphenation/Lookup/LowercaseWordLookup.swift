import Foundation

package struct LowercaseWordLookup: Equatable, Sendable
{
    package static let localeIdentifier = "en_US_POSIX"
    package let normalized: NormalizedWordLookup
    package let text: String
    package let boundaries: [HyphenationBoundary]

    package init(_ normalized: NormalizedWordLookup)
        throws(OwnedCandidateFailure)
    {
        guard normalized.text.count + 1 == normalized.boundaries.count
        else
        {
            throw .contextualCaseMapping
        }
        var text = ""
        var offset = 0
        var pairs = [HyphenationBoundary(
            source: normalized.sourceRange.lowerBound, lookup: 0
        )]
        for (character, boundary) in zip(
            normalized.text, normalized.boundaries.dropFirst()
        )
        {
            let part = Self.transform(String(character))
            guard !part.isEmpty
            else
            {
                throw .contextualCaseMapping
            }
            text.append(contentsOf: part)
            offset += part.utf16.count
            pairs.append(.init(
                source: boundary.source, lookup: offset
            ))
        }
        let whole = Self.transform(normalized.text)
        guard text.utf16.elementsEqual(whole.utf16)
        else
        {
            throw .contextualCaseMapping
        }
        self.normalized = normalized
        self.text = text
        boundaries = pairs
    }

    private static func transform(_ text: String) -> String
    {
        text.lowercased(with: Locale(identifier: localeIdentifier))
            .precomposedStringWithCanonicalMapping
    }

    package func sourceOffset(at lookup: Int)
        throws(OwnedCandidateFailure) -> Int
    {
        guard let boundary = boundaries.first(where: { $0.lookup == lookup })
        else
        {
            throw .unmappedLowercase(lookup)
        }
        return boundary.source
    }
}
