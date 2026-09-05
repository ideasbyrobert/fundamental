package struct IdentifiedSemanticBlock: Equatable, Sendable
{
    package let blockID: FundamentalBlockID
    package let block: SemanticBlock

    package init(
        blockID: FundamentalBlockID,
        block: SemanticBlock
    )
    {
        self.blockID = blockID
        self.block = block
    }
}
