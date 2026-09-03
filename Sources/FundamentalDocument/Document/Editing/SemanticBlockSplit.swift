struct SemanticBlockSplit: Equatable, Sendable
{
    let point: DocumentPoint
    let continuationBlockID: FundamentalBlockID

    init?(
        point: DocumentPoint,
        continuationBlockID: FundamentalBlockID
    )
    {
        guard continuationBlockID != point.blockID
        else
        {
            return nil
        }

        self.point = point
        self.continuationBlockID = continuationBlockID
    }
}
