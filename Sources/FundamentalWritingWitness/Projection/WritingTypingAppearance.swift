import AppKit
import FundamentalDocument

@MainActor
struct WritingTypingAppearance
{
    let attributes: [NSAttributedString.Key: Any]

    init?(_ projection: WritingProjection)
    {
        let blocks = projection.snapshot.snapshot.document.content.blocks
        let caret = projection.selection.location
        guard let index = projection.map.spans.lastIndex(where:
            { $0.range.location <= caret }),
              case let .direct(traits) = projection.snapshot.typingAttributes(
                  in: projection.snapshot.selection.range
              )
        else
        {
            return nil
        }
        var ordinal = blocks[..<index].reversed().prefix
        {
            if case let .listItem(item) = $0.block
            {
                return item.kind == .numbered
            }
            return false
        }.count
        guard let base = WritingTypography.attributes(
            for: blocks[index].block, ordinal: &ordinal
        ), let font = base[.font] as? NSFont,
              let inline = WritingInlineAppearance.attributes(
                  traits: traits, font: font
              )
        else
        {
            return nil
        }
        let span = projection.map.spans[index]
        let line = (projection.text as NSString).paragraphRange(for: NSRange(
            location: caret, length: 0
        ))
        var result = WritingBlockAppearance.line(base,
            first: line.location == span.range.location,
            last: NSMaxRange(line) >= NSMaxRange(span.range) +
                span.separatorLength)
        result.merge(inline) { _, next in next }
        attributes = result
    }
}
