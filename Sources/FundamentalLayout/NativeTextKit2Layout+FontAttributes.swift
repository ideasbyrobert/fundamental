import AppKit
import CoreText
import FundamentalProjection

extension NativeTextKit2Layout
{
    func attributes(
        font: NSFont,
        traits: Set<ProjectedInlineTrait>
    ) throws -> [NSAttributedString.Key: Any]
    {
        var selectedFont = font
        var symbolic: NSFontDescriptor.SymbolicTraits = []
        if traits.contains(.strong)
        {
            symbolic.insert(.bold)
        }
        if traits.contains(.emphasis)
        {
            symbolic.insert(.italic)
        }
        if traits.contains(.inlineCode)
        {
            selectedFont = .monospacedSystemFont(
                ofSize: font.pointSize,
                weight: .regular
            )
        }
        if !symbolic.isEmpty
        {
            guard let converted = NSFont(
                descriptor: selectedFont.fontDescriptor
                    .withSymbolicTraits(symbolic),
                size: selectedFont.pointSize
            )
            else
            {
                throw LayoutFailure.missingResolvedFontIdentity
            }
            selectedFont = converted
        }
        var attributes: [NSAttributedString.Key: Any] = [
            .font: selectedFont
        ]
        if traits.contains(.underline)
        {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        if traits.contains(.strikethrough)
        {
            attributes[.strikethroughStyle] =
                NSUnderlineStyle.single.rawValue
        }
        if traits.contains(.superscript)
        {
            attributes[.baselineOffset] = font.pointSize * 0.3
        }
        if traits.contains(.subscriptText)
        {
            attributes[.baselineOffset] = -font.pointSize * 0.2
        }
        return attributes
    }

}
