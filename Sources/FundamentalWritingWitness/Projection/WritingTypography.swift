import AppKit
import FundamentalDocument

@MainActor
enum WritingTypography
{
    static let marker = NSAttributedString.Key("FundamentalListMarker")
    static let body = attributes(size: 20, weight: .regular, after: 12)
    static let title = attributes(size: 34, weight: .semibold, after: 20)
    static let list = attributes(
        size: 20, weight: .regular, after: 4, indent: 32
    )
    static let headings = [28.0, 26, 22, 21, 20, 20].map
    {
        attributes(size: $0, weight: .semibold, before: 18, after: 8)
    }

    static func attributes(
        size: CGFloat, weight: NSFont.Weight,
        before: CGFloat = 0, after: CGFloat, indent: CGFloat = 0
    ) -> [NSAttributedString.Key: Any]
    {
        let base = NSFont.systemFont(ofSize: size, weight: weight)
        let font = base.fontDescriptor.withDesign(.serif).flatMap
        {
            NSFont(descriptor: $0, size: size)
        } ?? base
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        paragraph.paragraphSpacingBefore = before
        paragraph.paragraphSpacing = after
        paragraph.firstLineHeadIndent = indent
        paragraph.headIndent = indent
        return [.font: font, .paragraphStyle: paragraph.copy(),
                .foregroundColor: NSColor.textColor]
    }

    static func attributes(
        for block: SemanticBlock, ordinal: inout Int
    ) -> [NSAttributedString.Key: Any]?
    {
        if case let .listItem(item) = block
        {
            ordinal = item.kind == .numbered ? ordinal + 1 : 0
            var attributes = list
            attributes[marker] = item.kind == .numbered ? "\(ordinal)." : "•"
            return attributes
        }
        ordinal = 0
        switch block
        {
        case .paragraph:
            return body
        case .heading(.title):
            return title
        case let .heading(.section(heading)):
            return headings[heading.level.rawValue - 1]
        case .code:
            return code
        case .listItem, .table:
            return nil
        }
    }
}
