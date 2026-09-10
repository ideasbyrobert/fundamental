import AppKit

extension MacAccessibilityElement
{
    package override func accessibilityIndex() -> Int
    {
        semantics.listItem?.position.index ?? super.accessibilityIndex()
    }

    package override func accessibilityNumberOfCharacters() -> Int
    {
        guard case let .listText(_, source) = semantics
        else
        {
            return super.accessibilityNumberOfCharacters()
        }
        return source.utf16.count
    }

    package override func accessibilityAttributedString(
        for range: NSRange
    ) -> NSAttributedString?
    {
        guard case let .listText(item, source) = semantics
        else
        {
            return super.accessibilityAttributedString(for: range)
        }
        guard Self.validTextRange(range, source: source)
        else
        {
            return nil
        }
        let value = NSAttributedString(string: source, attributes: [
            .accessibilityListItemPrefix:
                NSAttributedString(string: item.label),
            .accessibilityListItemIndex: NSNumber(value: item.position.index),
            .accessibilityListItemLevel: NSNumber(value: 0)
        ])
        return value.attributedSubstring(from: range)
    }
}
