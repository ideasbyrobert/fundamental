extension CodeConversionResult
{
    static func split(
        _ source: [IdentifiedSemanticBlock], style: CanonicalBlockStyle,
        continuationBlockIDs: [FundamentalBlockID]
    ) -> CodeConversionResult?
    {
        var blocks: [IdentifiedSemanticBlock] = []
        var mappings: [CodeConversionPointMap] = []
        var nextIdentity = 0
        for block in source
        {
            guard let editable = EditableSemanticBlock(block.block)
            else
            {
                return nil
            }
            guard case .code = editable
            else
            {
                blocks.append(IdentifiedSemanticBlock(
                    blockID: block.blockID,
                    block: style.semanticBlock(runs: editable.runs)
                ))
                continue
            }
            guard let lines = CodeConversionLines(runs: editable.runs),
                  lines.ranges.count - 1 <=
                      continuationBlockIDs.count - nextIdentity
            else
            {
                return nil
            }
            for (index, range) in lines.ranges.enumerated()
            {
                let identity: FundamentalBlockID
                if index == 0
                {
                    identity = block.blockID
                }
                else
                {
                    identity = continuationBlockIDs[nextIdentity]
                    nextIdentity += 1
                }
                blocks.append(IdentifiedSemanticBlock(
                    blockID: identity,
                    block: style.semanticBlock(runs: lines.runs[index])
                ))
                mappings.append(CodeConversionPointMap(
                    sourceBlockID: block.blockID,
                    sourceRange: range.lowerBound ... range.upperBound,
                    blockID: identity, offset: 0
                ))
            }
        }
        guard nextIdentity == continuationBlockIDs.count
        else
        {
            return nil
        }
        return CodeConversionResult(blocks: blocks, mappings: mappings)
    }
}
