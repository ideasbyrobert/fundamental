import AppKit

extension WritingTextView
{
    override func readSelection(
        from pasteboard: NSPasteboard,
        type: NSPasteboard.PasteboardType
    ) -> Bool
    {
        guard type == .string,
              let bridge = delegate as? WritingNativeBridge,
              bridge.finishComposition(in: self)
        else
        {
            return false
        }
        return super.readSelection(from: pasteboard, type: type)
    }

    override func paste(_ sender: Any?)
    {
        let pasteboard = sender as? NSPasteboard ?? .general
        _ = readSelection(from: pasteboard, type: .string)
    }

    override func pasteAsPlainText(_ sender: Any?)
    {
        paste(sender)
    }

    override func pasteAsRichText(_ sender: Any?)
    {
    }

    override func copy(_ sender: Any?)
    {
        guard let bridge = delegate as? WritingNativeBridge
        else
        {
            return
        }
        let pasteboard = sender as? NSPasteboard ?? .general
        _ = bridge.copy(to: pasteboard, from: self)
    }
}
