package struct IdentifiedSemanticBlock: Equatable, Sendable
{
    package let blockID: FundamentalBlockID
    package let block: SemanticBlock

    init(
        blockID: FundamentalBlockID,
        block: SemanticBlock
    )
    {
        self.blockID = blockID
        self.block = block
    }
}
