import Foundation
import FundamentalDocument

@MainActor
package struct StagedParagraphComposition
{
    package let paragraph: ParagraphComposition
    package let searches: [StagedParagraphPath]

    package init(
        _ collection: ParagraphHyphens, width: Double,
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
    }

    package init(_ original: ParagraphComposition, width: Double) throws
    {
        try self.init(
            collection: original.collection, width: width,
            attributes: original.attributes
        )
    }

    package init(_ original: ParagraphComposition) throws
    {
        try self.init(original, width: original.width)
    }
}
