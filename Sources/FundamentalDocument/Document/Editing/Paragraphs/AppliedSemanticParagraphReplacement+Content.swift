extension AppliedSemanticParagraphReplacement
{
    static func content(
        _ replacement: SemanticParagraphReplacement,
        range: ResolvedParagraphReplacement,
        in source: CanonicalDocument
    ) -> CanonicalDocumentContent?
    {
        let identities = [range.lower.point.blockID] +
            replacement.continuationBlockIDs
        let last = replacement.paragraphs.count - 1
        let inserted = replacement.paragraphs.enumerated().map
        {
            index, paragraph in
            let prefix = index == 0 ? range.prefix : []
            let suffix = index == last ? range.suffix : []
            let runs = prefix + paragraph.runs + suffix
            let block = index == 0 ? range.leadingBlock.replacingRuns(runs) :
                range.leadingBlock.continuing(runs: runs)
            return IdentifiedSemanticBlock(
                blockID: identities[index],
                block: block
            )
        }
        var blocks = source.content.blocks
        blocks.replaceSubrange(
            range.lower.blockIndex ... range.upper.blockIndex, with: inserted
        )
        guard let first = blocks.first
        else
        {
            return nil
        }
        return CanonicalDocumentContent(
            firstBlock: first, remainingBlocks: Array(blocks.dropFirst())
        )
    }

    static func caretOffset(
        _ replacement: SemanticParagraphReplacement,
        range: ResolvedParagraphReplacement
    ) -> DocumentUTF16Offset?
    {
        var count = replacement.paragraphs.count == 1 ?
            range.lower.point.utf16Offset.value : 0
        for run in replacement.paragraphs.last?.runs ?? []
        {
            let (next, overflow) = count.addingReportingOverflow(
                run.text.utf16.count
            )
            guard !overflow
            else
            {
                return nil
            }
            count = next
        }
        return DocumentUTF16Offset(count)
    }
}
