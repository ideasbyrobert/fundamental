import AppKit

extension WritingTextView
{
    override func keyDown(with event: NSEvent)
    {
        if routeCompositionShortcut(event)
        {
            return
        }
        if event.keyCode == 53,
           let bridge = delegate as? WritingNativeBridge,
           bridge.composition != nil
        {
            cancelOperation(nil)
            return
        }
        super.keyDown(with: event)
    }

    override func setMarkedText(
        _ value: Any, selectedRange: NSRange, replacementRange: NSRange
    )
    {
        guard let bridge = delegate as? WritingNativeBridge
        else
        {
            return
        }
        if bridge.composing
        {
            super.setMarkedText(value, selectedRange: selectedRange,
                                replacementRange: replacementRange)
            return
        }
        bridge.mark(value, selected: selectedRange, replacing: replacementRange,
                    in: self)
        {
            super.setMarkedText(value, selectedRange: selectedRange,
                                replacementRange: replacementRange)
        }
    }

    override func insertText(_ value: Any, replacementRange: NSRange)
    {
        if let bridge = delegate as? WritingNativeBridge,
           !bridge.composing, bridge.composition != nil
        {
            bridge.commitComposition(value, replacing: replacementRange,
                                     in: self)
            return
        }
        super.insertText(value, replacementRange: replacementRange)
    }

    override func unmarkText()
    {
        if let bridge = delegate as? WritingNativeBridge,
           !bridge.composing, bridge.composition != nil
        {
            bridge.finishComposition(in: self)
            return
        }
        super.unmarkText()
    }

    override func cancelOperation(_ sender: Any?)
    {
        if let bridge = delegate as? WritingNativeBridge,
           bridge.composition != nil
        {
            bridge.project(in: self)
            inputContext?.discardMarkedText()
            return
        }
        super.cancelOperation(sender)
    }

    override func resignFirstResponder() -> Bool
    {
        guard let bridge = delegate as? WritingNativeBridge,
              bridge.finishComposition(in: self)
        else
        {
            return false
        }
        return super.resignFirstResponder()
    }
}
