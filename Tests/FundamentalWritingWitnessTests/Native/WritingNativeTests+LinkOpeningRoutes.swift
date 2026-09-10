import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("grouped link commands open once without changing editing state",
          arguments: [false, true])
    func linkOpeningRoutes(_ toolbar: Bool) throws
    {
        let window = try WritingTestWindow.linked()
        defer
        {
            window.close()
        }
        window.select(1, 4)
        let before = window.storage
        var opened: [URL] = []
        window.controller.openDestination = { opened.append($0); return true }
        let item: NSMenuItem
        if toolbar
        {
            item = try window.openLinkChoice()
            let popup = window.controller.formatting.text
            popup.select(item)
            #expect(popup.sendAction(popup.action, to: popup.target))
        }
        else
        {
            let format = WritingApplicationMenu.formatMenu()
            let menu = try #require(format.item(withTitle: "Text Style")?
                .submenu)
            item = try #require(menu.item(withTitle: "Open Link"))
            menu.delegate?.menuNeedsUpdate?(menu)
            #expect(window.controller.validateUserInterfaceItem(item))
            try window.performFormat(item)
            withExtendedLifetime(format) {}
        }
        #expect(opened.map(\.absoluteString) ==
            ["https://example.invalid/e%CC%81"])
        #expect(window.storage == before && !window.session.isDirty)
        #expect(window.view.selectedRange() == NSRange(location: 1, length: 4))
        #expect(window.controller.documentWindow.attachedSheet == nil)
    }

    @Test("a failed workspace open presents feedback without editing")
    func linkOpeningFailure() throws
    {
        let window = try WritingTestWindow.linked()
        defer
        {
            window.close()
        }
        let before = window.storage
        var count = 0
        window.controller.openDestination = { _ in count += 1; return false }
        let item = try window.openLinkChoice()
        window.controller.openLink(item)
        #expect(count == 1)
        #expect(window.controller.documentWindow.attachedSheet != nil)
        #expect(!window.controller.validateOpenLink(item))
        window.controller.openLink(item)
        #expect(count == 1 && window.storage == before)
        #expect(!window.session.isDirty)
    }
}
