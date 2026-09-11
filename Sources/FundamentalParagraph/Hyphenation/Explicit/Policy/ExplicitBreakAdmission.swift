enum ExplicitBreakAdmission
{
    static func outcome(
        mark: SourceHyphenationMark, group: MarkedWordGroup,
        source: ParagraphWordSource
    ) -> ExplicitBreakOutcome
    {
        guard case let .resolved(scope) = group.resolution
        else
        {
            return .refused(.sourceScope)
        }
        guard PatternLanguage(rawValue: scope.language.value) != nil
        else
        {
            return .refused(.unsupportedLanguage(scope.language.value))
        }
        guard mark.mark.isExplicitBreak
        else
        {
            return .refused(.notBreakMark)
        }
        let inhibitors = group.marks.filter { $0.mark.inhibitsExplicitBreaks }
        guard inhibitors.isEmpty
        else
        {
            return .refused(.protectedGroup(inhibitors))
        }
        let text = source.source
        guard text.isBoundary(mark.range.lowerBound),
              text.isBoundary(mark.range.upperBound)
        else
        {
            return .refused(.graphemeBoundary)
        }
        guard hasAlphabeticContext(mark, group: group, source: source)
        else
        {
            return .refused(.nonAlphabeticContext)
        }
        let fragments = source.fragments(in: mark.range).fragments
        guard fragments.count == 1,
              fragments[0].paragraphRange == mark.range
        else
        {
            return .refused(.ambiguousOwner)
        }
        return .opportunity(ExplicitHyphenOpportunity(
            mark: mark, owner: fragments[0],
            ink: mark.mark == .softHyphen ? .conditionalHyphen : .existing
        ))
    }
}
