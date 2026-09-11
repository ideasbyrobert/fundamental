import FundamentalDocument

extension ParagraphWordSource
{
    package func resolve(_ range: Range<Int>) -> WordScopeResolution
    {
        guard range.lowerBound >= 0, range.upperBound <= source.utf16.count
        else
        {
            return .refused(range, [.invalidBounds])
        }
        guard !range.isEmpty
        else
        {
            return .refused(range, [.emptyRange])
        }
        guard source.isBoundary(range.lowerBound),
              source.isBoundary(range.upperBound)
        else
        {
            return .refused(range, [.graphemeBoundary])
        }
        let fragments = fragments(in: range).fragments
        var languages: [SemanticLanguageIdentifier] = []
        var languageSpellings: Set<[UInt16]> = []
        var code: [Int] = []
        for fragment in fragments
        {
            let span = spans[fragment.runIndex]
            if languageSpellings.insert(Array(span.language.value.utf16))
                .inserted
            {
                languages.append(span.language)
            }
            if paragraph.runs[span.index].traits.contains(.inlineCode)
            {
                code.append(span.index)
            }
        }
        var refusals: [WordScopeRefusal] = []
        if languages.count != 1
        {
            refusals.append(.incompatibleLanguages(languages))
        }
        if !code.isEmpty
        {
            refusals.append(.inlineCode(code))
        }
        let endings = endings(in: range).ranges
        if !endings.isEmpty
        {
            refusals.append(.hardEndings(endings))
        }
        if !refusals.isEmpty
        {
            return .refused(range, refusals)
        }
        return .resolved(ResolvedWordScope(
            range: range, language: languages[0], fragments: fragments
        ))
    }
}
