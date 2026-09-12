import AppKit

extension WritingFindBar
{
    func configureControls()
    {
        query.placeholderString = "Find in Document"
        query.sendsWholeSearchString = true
        query.maximumRecents = 0
        replacement.placeholderString = "Replace with"
        count.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
        message.font = count.font
        message.textColor = .secondaryLabelColor
        previous.image = NSImage(systemSymbolName: "chevron.up",
                                  accessibilityDescription: "Previous Match")
        next.image = NSImage(systemSymbolName: "chevron.down",
                              accessibilityDescription: "Next Match")
        let controls: [(NSView, String, String)] = [
            (query, "Query", "Find in Document"),
            (replacement, "Replacement", "Replace with"),
            (count, "Count", "Matches"),
            (previous, "Previous", "Previous Match"),
            (next, "Next", "Next Match"),
            (done, "Done", "Done"),
            (replace, "Replace", "Replace"),
            (replaceAll, "ReplaceAll", "Replace All"),
            (message, "Message", "Find message")
        ]
        for (view, identifier, label) in controls
        {
            view.setAccessibilityIdentifier("FundamentalFind" + identifier)
            view.setAccessibilityLabel(label)
        }
        for button in [previous, next, done, replace, replaceAll]
        {
            button.bezelStyle = .rounded
            button.controlSize = .small
            button.setContentHuggingPriority(.required, for: .horizontal)
        }
        for field in [query, replacement]
        {
            field.setContentHuggingPriority(.defaultLow, for: .horizontal)
            field.setContentCompressionResistancePriority(
                .defaultLow, for: .horizontal
            )
            field.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
                .isActive = true
        }
        count.setContentCompressionResistancePriority(
            .required, for: .horizontal
        )
    }
}
