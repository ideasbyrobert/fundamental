import AppKit

@MainActor
final class WritingUIPasteboard
{
    private let board = NSPasteboard.general
    private let original: [[NSPasteboard.PasteboardType: Data]]
    private var ownedChange: Int

    init()
    {
        original = board.pasteboardItems?.map
        {
            item in
            item.types.reduce(into: [:])
            {
                result, type in
                result[type] = item.data(forType: type)
            }
        } ?? []
        ownedChange = board.changeCount
    }

    func write(_ text: String)
    {
        board.clearContents()
        board.setString(text, forType: .string)
        ownedChange = board.changeCount
    }

    func copiedText(expected: String) -> String?
    {
        let text = board.string(forType: .string)
        if text?.utf16.elementsEqual(expected.utf16) == true
        {
            ownedChange = board.changeCount
        }
        return text
    }

    func restore()
    {
        guard board.changeCount == ownedChange
        else
        {
            return
        }
        board.clearContents()
        let items = original.map
        {
            values in
            let item = NSPasteboardItem()
            for (type, data) in values
            {
                item.setData(data, forType: type)
            }
            return item
        }
        board.writeObjects(items)
    }
}
