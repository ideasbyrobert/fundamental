import AppKit

@MainActor
struct WritingTextPresentation
{
    let text: NSAttributedString
    let ranges: [NSRange]
    let attributes: [[NSAttributedString.Key: Any]]
    let selectedIndex: Int

    init?(_ projection: WritingProjection)
    {
        let content = NSMutableAttributedString(string: projection.text)
        let blocks = projection.snapshot.snapshot.document.content.blocks
        var attributes: [[NSAttributedString.Key: Any]] = []
        var ranges: [NSRange] = []
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
            let span = projection.map.spans[index]
            let range = NSRange(
                location: span.range.location,
                length: span.range.length + span.separatorLength
            )
            content.addAttributes(appearance, range: range)
            attributes.append(appearance)
            ranges.append(range)
        }
        text = content
        self.attributes = attributes
        self.ranges = ranges
        selectedIndex = projection.map.spans.lastIndex
        {
            $0.range.location <= projection.selection.location
        } ?? 0
    }

    func replace(in view: NSTextView)
    {
        view.textStorage?.setAttributedString(text)
        view.typingAttributes = attributes[selectedIndex]
        (view as? WritingTextView)?.terminalAttributes = attributes.last ?? [:]
        (view as? WritingTextView)?.hasListMarkers = attributes.contains
        {
            $0[WritingTypography.marker] != nil
        }
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
        for (range, appearance) in zip(ranges, attributes)
        {
            storage.addAttributes(appearance, range: range)
        }
        storage.endEditing()
        (view as? WritingTextView)?.terminalAttributes = attributes.last ?? [:]
        (view as? WritingTextView)?.hasListMarkers = attributes.contains
        {
            $0[WritingTypography.marker] != nil
        }
        view.needsDisplay = true
    }
}
