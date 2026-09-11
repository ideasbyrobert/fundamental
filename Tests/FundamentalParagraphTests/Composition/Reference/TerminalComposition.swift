@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
@MainActor
struct TerminalComposition
{
    let paragraph: ParagraphComposition
    let paths: [QualityPath]

    init(_ original: ParagraphComposition, width: Double) throws
    {
        var paths: [QualityPath] = []
        paragraph = try ParagraphComposition(
            recomposing: original, width: width
        )
        {
            cache, measure in
            let path = try TerminalOptimizer(
                cache: cache, width: measure
            ).optimize()
            paths.append(path)
            return try path.materializing(cache: cache, width: measure)
        }
        self.paths = paths
    }

    init(_ original: ParagraphComposition) throws
    {
        try self.init(original, width: original.width)
    }
}
