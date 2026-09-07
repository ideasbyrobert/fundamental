import AppKit

extension WritingTextView
{
    override func performKeyEquivalent(with event: NSEvent) -> Bool
    {
        if routeCompositionShortcut(event)
        {
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    func routeCompositionShortcut(_ event: NSEvent) -> Bool
    {
        guard event.modifierFlags.contains(.command),
              event.modifierFlags.intersection([.control, .option]).isEmpty,
              let bridge = delegate as? WritingNativeBridge,
              bridge.composition != nil,
              let characters = event.charactersIgnoringModifiers,
              let shortcut = NSEvent.keyEvent(
                  with: .keyDown, location: event.locationInWindow,
                  modifierFlags: event.modifierFlags,
                  timestamp: event.timestamp, windowNumber: event.windowNumber,
                  context: nil, characters: characters,
                  charactersIgnoringModifiers: characters,
                  isARepeat: event.isARepeat, keyCode: event.keyCode
              )
        else
        {
            return false
        }
        return NSApp.mainMenu?.performKeyEquivalent(with: shortcut) == true
    }
}
