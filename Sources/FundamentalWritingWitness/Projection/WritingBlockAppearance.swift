import AppKit

@MainActor
enum WritingBlockAppearance
{
    static func apply(
        _ appearance: [NSAttributedString.Key: Any],
        to content: NSMutableAttributedString, span: WritingParagraphSpan
    ) -> [NSAttributedString.Key: Any]
    {
        let range = NSRange(location: span.range.location,
                            length: span.range.length + span.separatorLength)
        guard range.length > 0
        else
        {
            return appearance
        }
        if appearance[WritingTypography.marker] == nil,
           let paragraph = appearance[.paragraphStyle] as? NSParagraphStyle,
           paragraph.paragraphSpacing == 0,
           paragraph.paragraphSpacingBefore == 0,
           paragraph.firstLineHeadIndent == paragraph.headIndent
        {
            content.addAttributes(appearance, range: range)
            return appearance
        }
        let source = content.string as NSString
        let end = NSMaxRange(range)
        let first = NSIntersectionRange(range, source.paragraphRange(
            for: NSRange(location: range.location, length: 0)
        ))
        let terminal = span.separatorLength == 0 && source.paragraphRange(
            for: NSRange(location: end, length: 0)
        ).location == end
        if first == range && !terminal
        {
            content.addAttributes(appearance, range: range)
            return appearance
        }
        content.addAttributes(line(appearance, first: false, last: false),
                              range: range)
        let leading = line(appearance, first: true,
                           last: NSMaxRange(first) == end && !terminal)
        content.addAttributes(leading, range: first)
        let trailing = line(appearance, first: false, last: true)
        if terminal
        {
            return trailing
        }
        let last = NSIntersectionRange(range, source.paragraphRange(
            for: NSRange(location: end - 1, length: 0)
        ))
        if last == first
        {
            return leading
        }
        content.addAttributes(trailing, range: last)
        return trailing
    }

    static func line(
        _ appearance: [NSAttributedString.Key: Any], first: Bool, last: Bool
    ) -> [NSAttributedString.Key: Any]
    {
        var result = appearance
        if !first
        {
            result.removeValue(forKey: WritingTypography.marker)
        }
        if let source = appearance[.paragraphStyle] as? NSParagraphStyle,
           let paragraph = source.mutableCopy() as? NSMutableParagraphStyle
        {
            if !first
            {
                paragraph.paragraphSpacingBefore = 0
                paragraph.firstLineHeadIndent = paragraph.headIndent
            }
            if !last
            {
                paragraph.paragraphSpacing = 0
            }
            result[.paragraphStyle] = paragraph.copy()
        }
        return result
    }
}
