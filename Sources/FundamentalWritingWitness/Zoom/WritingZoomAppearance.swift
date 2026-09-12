import AppKit

@MainActor
struct WritingZoomAppearance
{
    static func scale(
        _ attributes: [NSAttributedString.Key: Any], by zoom: WritingZoom
    ) -> [NSAttributedString.Key: Any]?
    {
        guard zoom.percentage != 100
        else
        {
            return attributes
        }
        let factor = zoom.scale
        guard let font = attributes[.font] as? NSFont,
              let resized = NSFont(descriptor: font.fontDescriptor,
                                   size: font.pointSize * factor),
              let style = attributes[.paragraphStyle] as? NSParagraphStyle,
              let paragraph = style.mutableCopy() as? NSMutableParagraphStyle
        else
        {
            return nil
        }
        paragraph.lineSpacing *= factor
        paragraph.paragraphSpacing *= factor
        paragraph.paragraphSpacingBefore *= factor
        paragraph.firstLineHeadIndent *= factor
        paragraph.headIndent *= factor
        paragraph.tailIndent *= factor
        paragraph.minimumLineHeight *= factor
        paragraph.maximumLineHeight *= factor
        paragraph.defaultTabInterval *= factor
        paragraph.tabStops = style.tabStops.map
        {
            NSTextTab(textAlignment: $0.alignment,
                      location: $0.location * factor, options: $0.options)
        }
        var result = attributes
        result[.font] = resized
        result[.paragraphStyle] = paragraph.copy()
        return result
    }
}
