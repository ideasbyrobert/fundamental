import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingTestWindow
{
    func formatChoice(_ title: String, group: String) throws -> NSMenuItem
    {
        let menu = WritingApplicationMenu.formatMenu()
        let submenu = try #require(menu.item(withTitle: group)?.submenu)
        return try #require(submenu.item(withTitle: title))
    }

    func performFormat(_ item: NSMenuItem) throws
    {
        let action = try #require(item.action)
        #expect(item.target == nil)
        let target = NSApp.target(forAction: action, to: nil, from: item)
            as? WritingWindowController
        #expect(target === controller)
        #expect(NSApp.sendAction(action, to: nil, from: item))
    }
}
