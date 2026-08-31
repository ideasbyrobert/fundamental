struct IdentifiedSemanticBlock: Equatable, Sendable
{
    let blockID: FundamentalBlockID
    let block: SemanticBlock

    init(
        blockID: FundamentalBlockID,
        block: SemanticBlock
    )
    {
        self.blockID = blockID
        self.block = block
    }
}
