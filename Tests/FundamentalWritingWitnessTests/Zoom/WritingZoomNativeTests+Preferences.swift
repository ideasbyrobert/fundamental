import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingZoomNativeTests
{
    @Test("new windows inherit zoom while existing documents keep their view")
    func preference() throws
    {
        let name = "FundamentalZoomTest." + UUID().uuidString
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let preferences = WritingZoomPreferences(defaults: defaults)
        #expect(preferences.zoom == WritingZoom())
        defaults.set(55, forKey: WritingZoomPreferences.key)
        #expect(preferences.zoom == WritingZoom())
        preferences.store(WritingZoom(130))
        let first = try WritingTestWindow("First")
        let second = try WritingTestWindow("Second")
        defer
        {
            first.close()
            second.close()
        }
        let delegate = WritingApplicationDelegate(controller: first.controller,
                                                   zoomPreferences: preferences)
        #expect(first.controller.bridge.zoom == WritingZoom(130))
        #expect(first.controller.applyZoom(WritingZoom(160)))
        delegate.retain(second.controller)
        #expect(second.controller.bridge.zoom == WritingZoom(160))
        #expect(first.controller.bridge.zoom == WritingZoom(160))
        second.controller.zoomOut(nil)
        #expect(second.controller.bridge.zoom == WritingZoom(150))
        #expect(first.controller.bridge.zoom == WritingZoom(160))
        #expect(WritingZoomPreferences(defaults: defaults).zoom ==
            WritingZoom(150))
    }

    @Test("View menu offers bounded zoom and both plus-key spellings")
    func menu() throws
    {
        let window = try WritingTestWindow("View")
        defer { window.close() }
        let menu = WritingApplicationMenu.viewMenu()
        #expect(menu.items.filter { !$0.isHidden }.map(\.title) ==
            ["Zoom In", "Zoom Out", "Actual Size"])
        #expect(menu.items.map(\.keyEquivalent) == ["+", "-", "0", "="])
        #expect(menu.items.allSatisfy
            { $0.keyEquivalentModifierMask == [.command] })
        #expect(menu.items[3].allowsKeyEquivalentWhenHidden)
        window.controller.applyZoom(WritingZoom(200))
        #expect(!window.controller.validateUserInterfaceItem(menu.items[0]))
        #expect(window.controller.validateUserInterfaceItem(menu.items[1]))
        window.controller.applyZoom(WritingZoom(50))
        #expect(!window.controller.validateUserInterfaceItem(menu.items[1]))
        window.controller.actualSize(nil)
        #expect(window.controller.validateUserInterfaceItem(menu.items[2]))
        #expect(menu.items[2].state == .on)
    }
}
