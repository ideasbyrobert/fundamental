struct ResolvedParagraphReplacement: Equatable, Sendable
{
    let lower: ResolvedDocumentPoint
    let upper: ResolvedDocumentPoint
    let prefix: [SemanticRun]
    let suffix: [SemanticRun]

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
        for block in blocks[lower.blockIndex ... upper.blockIndex]
        {
            guard case .paragraph = block.block
            else
            {
                return nil
            }
        }
        guard case let .paragraph(first) = blocks[lower.blockIndex].block,
              case let .paragraph(last) = blocks[upper.blockIndex].block,
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
    }
}
