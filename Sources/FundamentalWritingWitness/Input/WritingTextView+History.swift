import AppKit

extension WritingTextView
{
    @objc
    func undoCanonicalEdit(_ sender: Any?)
    {
        guard let bridge = delegate as? WritingNativeBridge
        else
        {
            return
        }
        if bridge.composition != nil
        {
            bridge.project(in: self)
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
        if bridge.composition != nil
        {
            bridge.project(in: self)
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
            return bridge.composition != nil || bridge.session.canUndo
        case #selector(redoCanonicalEdit):
            return bridge.composition != nil || bridge.session.canRedo
        default:
            return super.validateUserInterfaceItem(item)
        }
    }
}
