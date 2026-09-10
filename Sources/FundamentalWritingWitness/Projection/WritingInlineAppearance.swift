import AppKit
import FundamentalDocument

@MainActor
enum WritingInlineAppearance
{
    static func attributes(
        traits: Set<SemanticInlineTrait>, font: NSFont
    ) -> [NSAttributedString.Key: Any]?
    {
        var selected = font
        if traits.contains(.inlineCode)
        {
            let values = font.fontDescriptor.object(forKey: .traits)
                as? [NSFontDescriptor.TraitKey: Any]
            let weight = (values?[.weight] as? NSNumber)?.doubleValue ?? 0
            selected = .monospacedSystemFont(ofSize: font.pointSize,
                weight: NSFont.Weight(rawValue: CGFloat(weight)))
        }
        var symbolic = selected.fontDescriptor.symbolicTraits
        if traits.contains(.strong)
        {
            symbolic.insert(.bold)
        }
        if traits.contains(.emphasis)
        {
            symbolic.insert(.italic)
        }
        if symbolic != selected.fontDescriptor.symbolicTraits
        {
            guard let converted = NSFont(descriptor: selected.fontDescriptor
                .withSymbolicTraits(symbolic), size: selected.pointSize)
            else
            {
                return nil
            }
            selected = converted
        }
        var baseline: CGFloat = 0
        if traits.contains(.superscript)
        {
            baseline = font.pointSize * 0.3
        }
        if traits.contains(.subscriptText)
        {
            baseline = -font.pointSize * 0.2
        }
        return [
            .font: selected, .baselineOffset: baseline,
            .underlineStyle: traits.contains(.underline)
                ? NSUnderlineStyle.single.rawValue : 0,
            .strikethroughStyle: traits.contains(.strikethrough)
                ? NSUnderlineStyle.single.rawValue : 0
        ]
    }
}
