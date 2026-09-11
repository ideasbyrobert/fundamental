import FundamentalParagraph
import Foundation
import FundamentalDocument

extension ExplicitDisplayMap
{
    @MainActor
    package func attributed(
        using resolve: (SemanticRun) throws -> [NSAttributedString.Key: Any]
    ) throws -> NSAttributedString
    {
        let result = NSMutableAttributedString(string: "")
        for interval in occupied
        {
            let run = slice.source.paragraph.runs[
                interval.atom.fragment.runIndex
            ]
            let part = String(
                decoding: units[interval.range], as: UTF16.self
            )
            result.append(NSAttributedString(
                string: part, attributes: try resolve(run)
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
