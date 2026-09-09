struct ResolvedParagraphReplacement: Equatable, Sendable
{
    let lower: ResolvedDocumentPoint
    let upper: ResolvedDocumentPoint
    let prefix: [SemanticRun]
    let suffix: [SemanticRun]
    let leadingBlock: EditableSemanticBlock

    init?(
        _ replacement: SemanticParagraphReplacement,
        in source: CanonicalDocument
    )
    {
        let blocks = source.content.blocks
        guard blocks.allSatisfy({ EditableSemanticBlock($0.block) != nil }),
              let range = ResolvedDocumentRange(replacement.range, in: source)
        else
        {
            return nil
        }
        let lower = range.lowerBound
        let upper = range.upperBound
        guard let first = EditableSemanticBlock(blocks[lower.blockIndex].block),
              let last = EditableSemanticBlock(blocks[upper.blockIndex].block),
              let leading = SemanticRunPartition(
                  runs: first.runs, lowerBound: lower.point.utf16Offset,
                  upperBound: lower.point.utf16Offset
              ),
              let trailing = SemanticRunPartition(
                  runs: last.runs, lowerBound: upper.point.utf16Offset,
                  upperBound: upper.point.utf16Offset
              )
        else
        {
            return nil
        }
        self.lower = lower
        self.upper = upper
        prefix = leading.prefix
        suffix = trailing.suffix
        leadingBlock = first
    }
}
