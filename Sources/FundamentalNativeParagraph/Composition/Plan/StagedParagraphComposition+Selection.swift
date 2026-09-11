extension StagedParagraphComposition
{
    init(
        collection: ParagraphHyphens, width: Double,
        attributes: ParagraphAttributes
    ) throws
    {
        var searches: [StagedParagraphPath] = []
        paragraph = try ParagraphComposition(
            collection: collection, width: width, attributes: attributes
        )
        {
            cache, measure in
            let result = try StagedParagraphOptimizer(
                cache: cache, width: measure
            ).optimize()
            searches.append(result)
            return try result.path.materializing(cache: cache, width: measure)
        }
        self.searches = searches
    }
}
