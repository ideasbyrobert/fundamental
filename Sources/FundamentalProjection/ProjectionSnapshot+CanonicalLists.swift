import FundamentalDocument

extension ProjectionSnapshot
{
    static func projectBlocks(
        _ blocks: [IdentifiedSemanticBlock]
    ) -> [ProjectedBlock]
    {
        var projected: [ProjectedBlock] = []
        projected.reserveCapacity(blocks.count)
        var ordinal = 0
        while ordinal < blocks.count
        {
            let count = listCount(startingAt: ordinal, in: blocks)
            for position in ProjectedListPosition.positions(count: count)
            {
                projected.append(project(
                    blocks[ordinal], ordinal: ordinal, listPosition: position
                ))
                ordinal += 1
            }
        }
        return projected
    }

    private static func listCount(
        startingAt ordinal: Int, in blocks: [IdentifiedSemanticBlock]
    ) -> Int
    {
        guard case let .listItem(first) = blocks[ordinal].block
        else
        {
            return 1
        }
        var end = ordinal + 1
        while end < blocks.count
        {
            guard case let .listItem(next) = blocks[end].block,
                  next.kind == first.kind
            else
            {
                break
            }
            end += 1
        }
        return end - ordinal
    }
}
