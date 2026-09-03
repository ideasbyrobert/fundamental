package struct ProjectionSnapshot: Equatable, Sendable
{
    package let lineage: ProjectionLineage
    package let firstBlock: ProjectedBlock
    package let remainingBlocks: [ProjectedBlock]

    package var blocks: [ProjectedBlock]
    {
        [firstBlock] + remainingBlocks
    }
}
