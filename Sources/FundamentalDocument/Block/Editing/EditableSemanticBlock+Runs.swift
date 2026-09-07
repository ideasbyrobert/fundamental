extension EditableSemanticBlock
{
    func replacingRuns(_ runs: [SemanticRun]) -> SemanticBlock
    {
        switch self
        {
        case .paragraph:
            .paragraph(SemanticParagraph(runs: runs))
        case .heading(.title):
            .heading(.title(TitleSemanticHeading(runs: runs)))
        case let .heading(.section(heading)):
            .heading(.section(SectionSemanticHeading(
                runs: runs, level: heading.level
            )))
        case let .listItem(item):
            .listItem(SemanticListItem(kind: item.kind, runs: runs))
        case .code(.plain):
            .code(.plain(PlainSemanticCodeBlock(runs: runs)))
        case let .code(.languageTagged(block)):
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: runs, language: block.language
            )))
        }
    }

    var isProse: Bool
    {
        switch self
        {
        case .paragraph, .heading, .listItem:
            true
        case .code:
            false
        }
    }

    func continuing(runs: [SemanticRun]) -> SemanticBlock
    {
        if case .heading = self
        {
            return .paragraph(SemanticParagraph(runs: runs))
        }
        return replacingRuns(runs)
    }
}
