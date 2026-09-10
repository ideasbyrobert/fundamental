import AppKit
import FundamentalDocument

struct WritingInlineChoice: Equatable, Sendable
{
    let title: String
    let trait: SemanticInlineTrait
    let key: String

    static let all: [Self] = [
        Self(title: "Bold", trait: .strong, key: "b"),
        Self(title: "Italic", trait: .emphasis, key: "i"),
        Self(title: "Underline", trait: .underline, key: "u"),
        Self(title: "Strikethrough", trait: .strikethrough, key: ""),
        Self(title: "Inline Code", trait: .inlineCode, key: ""),
        Self(title: "Superscript", trait: .superscript, key: ""),
        Self(title: "Subscript", trait: .subscriptText, key: "")
    ]

    @MainActor
    static func selected(from sender: Any?) -> Self?
    {
        let item = (sender as? NSPopUpButton)?.selectedItem
            ?? sender as? NSMenuItem
        guard let value = item?.representedObject as? String
        else
        {
            return nil
        }
        return all.first { $0.trait.rawValue == value }
    }

    @MainActor
    func menuItem() -> NSMenuItem
    {
        let item = NSMenuItem(title: title,
            action: #selector(WritingWindowController.chooseTextStyle(_:)),
            keyEquivalent: key)
        item.representedObject = trait.rawValue
        return item
    }
}
