extension ParagraphComposition
{
    init(
        collection: ParagraphHyphens, width: Double,
        attributes: ParagraphAttributes,
        choose: (ParagraphEdgeCache, Double) throws -> ParagraphPath
    ) throws
    {
        guard width.isFinite, width > 0
        else
        {
            throw ParagraphFailure.invalidWidth
        }
        var segments: [ParagraphSegmentPlan] = []
        for line in collection.source.source.lines
        {
            let cache = ParagraphEdgeCache(
                collection: collection,
                candidates: try ParagraphBreakSet(collection, line: line),
                attributes: attributes
            )
            let path = try choose(cache, width)
            segments.append(try ParagraphSegmentPlan(
                cache: cache, path: path, width: width
            ))
        }
        self.collection = collection
        self.width = width
        self.attributes = attributes
        self.segments = segments
    }
}
