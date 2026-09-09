import AppKit

extension WritingTypography
{
    static let code: [NSAttributedString.Key: Any] =
    {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 2
        return [
            .font: NSFont.monospacedSystemFont(ofSize: 18, weight: .regular),
            .paragraphStyle: paragraph.copy(),
            .foregroundColor: NSColor.textColor
        ]
    }()
}
