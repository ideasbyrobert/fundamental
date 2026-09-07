extension AppliedSemanticBlockMerge
{
    static func isEditable(_ document: CanonicalDocument) -> Bool
    {
        document.content.blocks.allSatisfy
        {
            EditableSemanticBlock($0.block) != nil
        }
    }

    static func merging(
        _ leading: EditableSemanticBlock,
        with trailing: EditableSemanticBlock
    ) -> SemanticBlock?
    {
        let runs = leading.runs + trailing.runs
        switch (leading, trailing)
        {
        case let (.listItem(first), .listItem(last)):
            guard first.kind == last.kind
            else
            {
                return nil
            }
            return .listItem(SemanticListItem(
                kind: first.kind, runs: runs
            ))
        case (.paragraph, .paragraph):
            return .paragraph(SemanticParagraph(runs: runs))
        case (.heading(.title), .heading(.title)):
            return .heading(.title(TitleSemanticHeading(runs: runs)))
        case let (
            .heading(.section(leadingHeading)),
            .heading(.section(trailingHeading))
        ):
            guard leadingHeading.level == trailingHeading.level
            else
            {
                return nil
            }
            return .heading(.section(SectionSemanticHeading(
                runs: runs,
                level: leadingHeading.level
            )))
        case (.code(.plain), .code(.plain)):
            return .code(.plain(PlainSemanticCodeBlock(runs: runs)))
        case let (
            .code(.languageTagged(leadingCode)),
            .code(.languageTagged(trailingCode))
        ):
            guard leadingCode.language == trailingCode.language
            else
            {
                return nil
            }
            return .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: runs,
                language: leadingCode.language
            )))
        default:
            return nil
        }
    }

}
