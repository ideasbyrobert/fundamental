import FundamentalParagraph
import AppKit
import FundamentalDocument

@MainActor
struct ParagraphAttributes
{
    let values: [[NSAttributedString.Key: Any]]
    let source: ParagraphWordSource

    init(
        _ source: ParagraphWordSource,
        resolve: (SemanticRun) throws -> [NSAttributedString.Key: Any]
    ) throws
    {
        self.source = source
        values = try source.paragraph.runs.map
        {
            let attributes = try resolve($0)
            guard let font = attributes[.font] as? NSFont,
                  font.pointSize.isFinite, font.pointSize > 0
            else
            {
                throw ParagraphFailure.missingFont
            }
            guard !(attributes[.paragraphStyle] is NSMutableParagraphStyle)
            else
            {
                throw ParagraphFailure.mutableStyle
            }
            return attributes
        }
    }

    func attributed(_ display: HyphenatedDisplay) throws -> NSAttributedString
    {
        guard display.body.slice.source.source.utf16 == source.source.utf16,
              display.body.slice.source.paragraph == source.paragraph
        else
        {
            throw ParagraphFailure.changedSource
        }
        let result = NSMutableAttributedString(string: "")
        for interval in display.body.occupied
        {
            result.append(NSAttributedString(
                string: String(
                    decoding: display.body.units[interval.range], as: UTF16.self
                ),
                attributes: values[interval.atom.fragment.runIndex]
            ))
        }
        if case let .automatic(ink) = display.suffix
        {
            result.append(NSAttributedString(
                string: "‐", attributes: values[ink.styleOrigin.runIndex]
            ))
        }
        guard Array(result.string.utf16) == display.units
        else
        {
            throw ExplicitShapingFailure.displayLength
        }
        return NSAttributedString(attributedString: result)
    }
}
