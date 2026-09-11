extension ParagraphComposition
{
    init(
        recomposing original: ParagraphComposition, width: Double,
        choose: (ParagraphEdgeCache, Double) throws -> ParagraphPath
    ) throws
    {
        try self.init(
            collection: original.collection, width: width,
            attributes: original.attributes, choose: choose
        )
    }
}
