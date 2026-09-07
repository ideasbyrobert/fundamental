extension DocumentRecordCodec
{
    func decodeBlocks(_ value: Any) throws -> CanonicalDocumentContent
    {
        let reader = SemanticTableRecordCodec.self
        let values = try reader.array(value, path: ["blocks"])
        guard values.count <= limits.maximumBlocks
        else
        {
            throw DocumentRecordFailure.blockLimitExceeded
        }
        guard !values.isEmpty
        else
        {
            throw DocumentRecordFailure.invalidContent
        }
        let blocks = try values.enumerated().map
        {
            index, value in
            let path = ["blocks", String(index)]
            let object = try reader.object(value, path: path)
            try reader.requireKeys(object, ["blockID", "content"], path: path)
            let identity = try Self.identity(
                reader.required("blockID", in: object, path: path),
                path: path + ["blockID"]
            )
            let block = try SemanticBlockRecordCodec.decodeRecord(
                reader.required("content", in: object, path: path),
                path: path + ["content"]
            )
            return IdentifiedSemanticBlock(
                blockID: FundamentalBlockID(identity),
                block: block
            )
        }
        guard let content = CanonicalDocumentContent(
            firstBlock: blocks[0],
            remainingBlocks: Array(blocks.dropFirst())
        )
        else
        {
            throw DocumentRecordFailure.invalidContent
        }
        return content
    }
}
