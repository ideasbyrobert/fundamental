import AppKit

@MainActor
struct WritingTextPresentation
{
    let text: NSAttributedString
    let typingAttributes: [NSAttributedString.Key: Any]
    let terminalAttributes: [NSAttributedString.Key: Any]
    let hasListMarkers: Bool

    init?(_ projection: WritingProjection)
    {
        let content = NSMutableAttributedString(string: projection.text)
        let blocks = projection.snapshot.snapshot.document.content.blocks
        var terminal: [NSAttributedString.Key: Any] = [:]
        var hasMarkers = false
        var ordinal = 0
        for (index, block) in blocks.enumerated()
        {
            guard let appearance = WritingTypography.attributes(
                for: block.block, ordinal: &ordinal
            )
            else
            {
                return nil
            }
            terminal = WritingBlockAppearance.apply(
                appearance, to: content, span: projection.map.spans[index]
            )
            hasMarkers = hasMarkers ||
                appearance[WritingTypography.marker] != nil
        }
        text = content
        terminalAttributes = terminal
        hasListMarkers = hasMarkers
        let caret = projection.selection.location
        typingAttributes = caret < content.length
            ? content.attributes(at: caret, effectiveRange: nil) : terminal
    }

    func replace(in view: NSTextView)
    {
        view.textStorage?.setAttributedString(text)
        view.typingAttributes = typingAttributes
        (view as? WritingTextView)?.terminalAttributes = terminalAttributes
        (view as? WritingTextView)?.hasListMarkers = hasListMarkers
        view.needsDisplay = true
    }

    func restyle(in view: NSTextView)
    {
        guard let storage = view.textStorage, storage.length == text.length
        else
        {
            return
        }
        storage.beginEditing()
        storage.removeAttribute(WritingTypography.marker, range: NSRange(
            location: 0, length: storage.length
        ))
        text.enumerateAttributes(in: NSRange(location: 0, length: text.length))
        {
            appearance, range, _ in
            storage.addAttributes(appearance, range: range)
        }
        storage.endEditing()
        (view as? WritingTextView)?.terminalAttributes = terminalAttributes
        (view as? WritingTextView)?.hasListMarkers = hasListMarkers
        view.needsDisplay = true
    }
}
