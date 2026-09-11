package struct ExplicitParagraphHyphens: Sendable
{
    package static let policyVersion = 1
    let identity = ExplicitBreakOwner()
    package let source: ParagraphWordSource
    let groups: [MarkedWordGroup]
    let marks: [SourceHyphenationMark]
    let softMarks: [SourceHyphenationMark]
    package let records: [ExplicitHyphenRecord]

    package init(_ source: ParagraphWordSource)
    {
        let marked = MarkedParagraphGroups(source)
        self.source = source
        groups = marked.groups
        marks = marked.marks
        softMarks = marked.marks.filter { $0.mark == .softHyphen }
        records = marked.groups.enumerated().flatMap
        {
            index, group in
            group.marks.map
            {
                ExplicitHyphenRecord(
                    groupIndex: index, mark: $0,
                    outcome: ExplicitBreakAdmission.outcome(
                        mark: $0, group: group, source: source
                    )
                )
            }
        }
    }
}
