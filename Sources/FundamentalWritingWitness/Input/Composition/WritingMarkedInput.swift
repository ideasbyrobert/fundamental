import AppKit

@MainActor
struct WritingMarkedInput
{
    static let keys: Set<NSAttributedString.Key> = [
        .underlineStyle, .underlineColor, .backgroundColor, .markedClauseSegment
    ]

    let text: NSAttributedString

    init?(_ value: Any, attributes: [NSAttributedString.Key: Any])
    {
        guard let spelling = WritingCompositionRange.string(value)
        else
        {
            return nil
        }
        let result = NSMutableAttributedString(string: spelling,
                                                attributes: attributes)
        if let marked = value as? NSAttributedString
        {
            marked.enumerateAttributes(in: NSRange(location: 0,
                                                    length: marked.length))
            {
                attributes, range, _ in
                result.addAttributes(attributes.filter
                    { Self.keys.contains($0.key) }, range: range)
            }
        }
        text = result
    }
}
