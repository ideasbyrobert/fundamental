import Foundation
import FundamentalDocument

@MainActor
package struct ParagraphComposition
{
    package let collection: ParagraphHyphens
    package let width: Double
    let attributes: ParagraphAttributes
    package let segments: [ParagraphSegmentPlan]

    package init(
        _ collection: ParagraphHyphens, width: Double,
        resolve: (SemanticRun) throws -> [NSAttributedString.Key: Any]
    ) throws
    {
        self = try StagedParagraphComposition(
            collection, width: width, resolve: resolve
        ).paragraph
    }
}
