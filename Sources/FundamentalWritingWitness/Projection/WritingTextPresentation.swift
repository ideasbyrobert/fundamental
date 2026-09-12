import AppKit
import FundamentalDocument

@MainActor
struct WritingTextPresentation
{
    let text: NSAttributedString
    let typingAttributes: [NSAttributedString.Key: Any]
    let terminalAttributes: [NSAttributedString.Key: Any]
    let hasListMarkers: Bool

    init?(_ projection: WritingProjection, zoom: WritingZoom = WritingZoom())
    {
        guard let typing = WritingTypingAppearance(projection, zoom: zoom)
        else
        {
            return nil
        }
        let content = NSMutableAttributedString(string: projection.text)
        let blocks = projection.snapshot.snapshot.document.content.blocks
        var terminal: [NSAttributedString.Key: Any] = [:]
        var hasMarkers = false
        var ordinal = 0
        for (index, block) in blocks.enumerated()
        {
            guard let base = WritingTypography.attributes(
                for: block.block, ordinal: &ordinal
            ), let appearance = WritingZoomAppearance.scale(base, by: zoom)
            else
            {
                return nil
            }
            terminal = WritingBlockAppearance.apply(
                appearance, to: content, span: projection.map.spans[index]
            )
            guard let editable = EditableSemanticBlock(block.block),
                  let font = appearance[.font] as? NSFont,
                  WritingInlineRuns.apply(editable.runs, to: content,
                      in: projection.map.spans[index].range, font: font)
            else
            {
                return nil
            }
            hasMarkers = hasMarkers ||
                appearance[WritingTypography.marker] != nil
        }
        text = content
        terminalAttributes = terminal
        hasListMarkers = hasMarkers
        typingAttributes = typing.attributes
    }

    func replace(in view: NSTextView)
    {
        view.textStorage?.setAttributedString(text)
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
        let marked = WritingMarkedAppearance(view)
        storage.beginEditing()
        text.enumerateAttributes(in: NSRange(location: 0, length: text.length))
        {
            appearance, range, _ in
            storage.setAttributes(appearance, range: range)
        }
        marked.apply(to: storage)
        storage.endEditing()
        view.typingAttributes = typingAttributes
        (view as? WritingTextView)?.terminalAttributes = terminalAttributes
        (view as? WritingTextView)?.hasListMarkers = hasListMarkers
        view.needsDisplay = true
    }
}
