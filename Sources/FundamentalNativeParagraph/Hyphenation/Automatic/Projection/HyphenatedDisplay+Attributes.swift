import FundamentalParagraph
import Foundation
import FundamentalDocument

extension HyphenatedDisplay
{
    @MainActor
    package func attributed(
        using resolve: (SemanticRun) throws -> [NSAttributedString.Key: Any]
    ) throws -> NSAttributedString
    {
        let original = try body.attributed(using: resolve)
        let result = NSMutableAttributedString(attributedString: original)
        if case let .automatic(ink) = suffix
        {
            let run = body.slice.source.paragraph.runs[ink.styleOrigin.runIndex]
            result.append(NSAttributedString(
                string: "\u{2010}", attributes: try resolve(run)
            ))
        }
        guard Array(result.string.utf16) == units
        else
        {
            throw ExplicitShapingFailure.displayLength
        }
        return NSAttributedString(attributedString: result)
    }
}
