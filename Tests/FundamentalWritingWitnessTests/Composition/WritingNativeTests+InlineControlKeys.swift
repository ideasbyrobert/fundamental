import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("Command B I U use canonical Text commands during composition",
          arguments: [("b", UInt16(11), SemanticInlineTrait.strong),
                      ("i", 34, .emphasis), ("u", 32, .underline)])
    func inlineControlsKeys(_ input: (String, UInt16, SemanticInlineTrait))
        throws
    {
        let window = try WritingTestWindow(styles: [.body], texts: [""])
        let previous = NSApp.mainMenu
        defer
        {
            NSApp.mainMenu = previous
            window.close()
        }
        let menu = NSMenu(title: "Commands")
        let format = NSMenuItem(title: "Format", action: nil, keyEquivalent: "")
        format.submenu = WritingApplicationMenu.formatMenu()
        menu.addItem(format)
        NSApp.mainMenu = menu
        window.mark("é")
        let event = try #require(NSEvent.keyEvent(with: .keyDown,
            location: .zero, modifierFlags: [.command], timestamp: 1,
            windowNumber: window.controller.documentWindow.windowNumber,
            context: nil, characters: input.0,
            charactersIgnoringModifiers: input.0, isARepeat: false,
            keyCode: input.1))
        #expect(window.view.performKeyEquivalent(with: event))
        #expect(!window.view.hasMarkedText())
        #expect(window.session.history.undo.count == 1)
        try window.expectInline(input.2, .on)
        try window.key("X", code: 7)
        let runs = try WritingInlineFixture.runs(window.session.document)
        #expect(runs.last == SemanticRun(text: "X", traits: [input.2]))
        #expect(menu.performKeyEquivalent(with: event))
        try window.expectInline(input.2, .off)
        #expect(window.session.history.undo.count == 2)
    }
}
