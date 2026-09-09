import AppKit
import FundamentalDocument

enum WritingFormattingGroup: CaseIterable
{
    case paragraph
    case list

    var title: String
    {
        self == .paragraph ? "Paragraph Style" : "List"
    }

    var choices: [(title: String, style: CanonicalBlockStyle)]
    {
        switch self
        {
        case .paragraph:
            [("Body", .body), ("Title", .title), ("Heading", .heading),
             ("Subheading", .subheading), ("Code", .monostyled)]
        case .list:
            [("No List", .body), ("Bulleted", .bulleted),
             ("Numbered", .numbered)]
        }
    }

    @MainActor
    var action: Selector
    {
        self == .paragraph
            ? #selector(WritingWindowController.chooseParagraphStyle(_:))
            : #selector(WritingWindowController.chooseListStyle(_:))
    }

    @MainActor
    func style(from sender: Any?) -> CanonicalBlockStyle?
    {
        let item = (sender as? NSPopUpButton)?.selectedItem
            ?? sender as? NSMenuItem
        guard let value = item?.representedObject as? String
        else
        {
            return nil
        }
        return choices.first { $0.style.rawValue == value }?.style
    }
}
