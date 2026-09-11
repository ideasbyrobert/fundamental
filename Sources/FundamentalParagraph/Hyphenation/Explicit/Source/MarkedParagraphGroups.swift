struct MarkedParagraphGroups
{
    let groups: [MarkedWordGroup]
    let marks: [SourceHyphenationMark]

    init(_ source: ParagraphWordSource)
    {
        let marks = ParagraphHyphenationMarks(source.source).marks
        var groups: [MarkedWordGroup] = []
        func append(_ range: Range<Int>)
        {
            let match = ParagraphRangeSearch.intersecting(
                range, count: marks.count
            )
            {
                marks[$0].range
            }
            guard !match.indices.isEmpty
            else
            {
                return
            }
            groups.append(.init(
                range: range, marks: Array(marks[match.indices]),
                resolution: source.resolve(range)
            ))
        }
        var start = 0
        var offset = 0
        for character in source.source.text
        {
            let end = offset + character.utf16.count
            if !SpellingCharacter.belongs(character)
            {
                append(start..<offset)
                append(offset..<end)
                start = end
            }
            offset = end
        }
        append(start..<offset)
        self.groups = groups
        self.marks = marks
    }
}
