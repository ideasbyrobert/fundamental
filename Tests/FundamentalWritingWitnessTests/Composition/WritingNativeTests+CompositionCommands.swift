import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("registered shortcuts reach menus before input methods consume them",
          arguments: [false, true], ["s", "¨s", "S", "¨S"])
    func compositionMenuShortcut(
        _ windowEvent: Bool, _ characters: String
    ) throws
    {
        let window = try WritingTestWindow("A")
        let previous = NSApp.mainMenu
        defer
        {
            NSApp.mainMenu = previous
            window.close()
        }
        window.select(1)
        window.mark("é")
        var received = false
        let target = WritingCompositionMenuTarget
        {
            #expect(window.view.hasMarkedText())
            received = true
            window.view.unmarkText()
        }
        let menu = NSMenu()
        let shifted = characters.hasSuffix("S")
        let key = shifted ? "S" : "s"
        let item = NSMenuItem(title: "Accept", action:
            #selector(WritingCompositionMenuTarget.invoke), keyEquivalent: key)
        item.target = target
        menu.addItem(item)
        NSApp.mainMenu = menu
        let event = try #require(NSEvent.keyEvent(
            with: .keyDown, location: .zero,
            modifierFlags: shifted ? [.command, .shift] : [.command],
            timestamp: 1, windowNumber: window.controller.documentWindow
                .windowNumber,
            context: nil, characters: characters,
            charactersIgnoringModifiers: key,
            isARepeat: false, keyCode: 1
        ))
        if windowEvent
        {
            window.controller.documentWindow.sendEvent(event)
        }
        else
        {
            #expect(window.view.performKeyEquivalent(with: event))
        }
        #expect(received)
        #expect(!window.view.hasMarkedText())
        try window.expect("Aé", selection: NSRange(location: 2, length: 0))
    }
}
