import AppKit

@MainActor
struct WritingMarkedAppearance
{
    let spans: [(attributes: [NSAttributedString.Key: Any], range: NSRange)]

    init(_ view: NSTextView)
    {
        let range = view.markedRange()
        guard view.hasMarkedText(), let storage = view.textStorage,
              range.location <= storage.length,
              range.length <= storage.length - range.location
        else
        {
            spans = []
            return
        }
        var values: [([NSAttributedString.Key: Any], NSRange)] = []
        storage.enumerateAttributes(in: range)
        {
            attributes, range, _ in
            values.append((attributes.filter
                { WritingMarkedInput.keys.contains($0.key) }, range))
        }
        spans = values
    }

    func apply(to storage: NSTextStorage)
    {
        for span in spans
        {
            storage.addAttributes(span.attributes, range: span.range)
        }
    }
}
