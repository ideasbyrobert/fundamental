import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("native link click notifications never authorize navigation")
    func linkOpeningCallbackRefusal() throws
    {
        let window = try WritingTestWindow.linked()
        defer
        {
            window.close()
        }
        let bridge = window.controller.bridge
        let before = window.storage
        for index in [-1, 0, 1, 5, 6, Int.max]
        {
            #expect(bridge.textView(window.view,
                clickedOnLink: WritingScopeFixture.link, at: index))
        }
        for payload: Any in ["https://foreign.invalid",
                              " https://example.invalid/é ", 42]
        {
            #expect(bridge.textView(window.view, clickedOnLink: payload, at: 1))
        }
        #expect(bridge.textView(NSTextView(),
            clickedOnLink: WritingScopeFixture.link, at: 1))
        #expect(window.storage == before)
    }

    @Test("old link requests and superseded native projections cannot open")
    func linkOpeningStale() throws
    {
        let window = try WritingTestWindow.linked()
        defer
        {
            window.close()
        }
        let captured = try #require(try window.openLinkChoice().copy()
            as? NSMenuItem)
        window.select(1)
        let before = window.storage
        #expect(!window.controller.validateOpenLink(captured))
        window.controller.openLink(captured)
        #expect(window.storage == before)
        let bridge = window.controller.bridge
        window.session.submit(.typingScope(bridge.projection.observation,
                                            .link(nil)))
        let current = window.storage
        #expect(!window.controller.canResolveLink)
        #expect(bridge.textView(window.view,
            clickedOnLink: WritingScopeFixture.link, at: 1))
        #expect(window.storage == current)
    }
}
