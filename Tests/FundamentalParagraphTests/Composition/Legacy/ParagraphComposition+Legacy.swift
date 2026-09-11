@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Foundation
import FundamentalDocument

extension ParagraphComposition
{
    init(
        legacy collection: ParagraphHyphens, width: Double,
        resolve: (SemanticRun) throws -> [NSAttributedString.Key: Any]
    ) throws
    {
        guard width.isFinite, width > 0
        else
        {
            throw ParagraphFailure.invalidWidth
        }
        try self.init(
            collection: collection, width: width,
            attributes: ParagraphAttributes(collection.source, resolve: resolve)
        )
        {
            cache, measure in
            try LegacyParagraphOptimizer(
                cache: cache, width: measure
            ).optimize()
        }
    }
}
