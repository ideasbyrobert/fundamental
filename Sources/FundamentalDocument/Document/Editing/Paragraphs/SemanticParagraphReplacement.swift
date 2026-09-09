package struct SemanticParagraphReplacement: Equatable, Sendable
{
    let range: DocumentRange
    let paragraphs: [SemanticParagraph]
    let continuationBlockIDs: [FundamentalBlockID]

    package init?(
        range: DocumentRange,
        paragraphs: [SemanticParagraph],
        continuationBlockIDs: [FundamentalBlockID]
    )
    {
        guard !paragraphs.isEmpty,
              paragraphs.count - 1 == continuationBlockIDs.count,
              Set(continuationBlockIDs).count == continuationBlockIDs.count,
              !range.isCollapsed || paragraphs.count > 1 ||
                  paragraphs[0].runs.contains(where: { !$0.text.isEmpty })
        else
        {
            return nil
        }
        self.range = range
        self.paragraphs = paragraphs
        self.continuationBlockIDs = continuationBlockIDs
    }

    var affinity: PostEditCaretAffinity
    {
        paragraphs.count == 1 && paragraphs[0].runs.allSatisfy
        { $0.text.isEmpty } ? .preceding : .following
    }
}
