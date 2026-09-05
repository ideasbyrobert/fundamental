import AppKit

@MainActor
final class WritingTextView: NSTextView
{
    override func setMarkedText(
        _ string: Any,
        selectedRange: NSRange,
        replacementRange: NSRange
    )
    {
    }

    override func readSelection(
        from pasteboard: NSPasteboard,
        type: NSPasteboard.PasteboardType
    ) -> Bool
    {
        guard type == .string
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

    @objc
    func undoCanonicalEdit(_ sender: Any?)
    {
        guard let bridge = delegate as? WritingNativeBridge
        else
        {
            return
        }
        bridge.move(.undo, in: self)
    }

    @objc
    func redoCanonicalEdit(_ sender: Any?)
    {
        guard let bridge = delegate as? WritingNativeBridge
        else
        {
            return
        }
        bridge.move(.redo, in: self)
    }

    override func validateUserInterfaceItem(
        _ item: any NSValidatedUserInterfaceItem
    ) -> Bool
    {
        guard let bridge = delegate as? WritingNativeBridge
        else
        {
            return false
        }
        switch item.action
        {
        case #selector(undoCanonicalEdit):
            return bridge.session.canUndo
        case #selector(redoCanonicalEdit):
            return bridge.session.canRedo
        default:
            return super.validateUserInterfaceItem(item)
        }
    }

    override func setFrameSize(_ newSize: NSSize)
    {
        super.setFrameSize(newSize)
        let inset = max(24, (newSize.width -
            WritingSurfacePolicy.readableMeasure) / 2)
        if textContainerInset.width != inset
        {
            textContainerInset = NSSize(width: inset, height: 32)
        }
    }
}
