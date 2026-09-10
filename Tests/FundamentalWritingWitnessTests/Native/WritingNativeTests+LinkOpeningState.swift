import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("composition and inactive windows cannot follow links")
    func linkOpeningInteractionState() throws
    {
        let window = try WritingTestWindow.linked()
        defer
        {
            window.close()
        }
        let captured = try window.openLinkChoice()
        let other = try WritingTestWindow("Other document")
        #expect(!window.controller.validateOpenLink(captured))
        window.controller.openLink(captured)
        other.close()
        try WritingTestApplication.activate(window.controller)
        window.mark("~")
        let before = window.storage
        let composition = try #require(window.controller.bridge.composition)
        #expect(!window.controller.canResolveLink)
        #expect(window.controller.bridge.textView(window.view,
            clickedOnLink: WritingScopeFixture.link, at: 1))
        #expect(window.storage == before)
        let current = try #require(window.controller.bridge.composition)
        #expect(current.baseline == composition.baseline)
        #expect(current.range == composition.range)
        #expect(current.selection == composition.selection)
        #expect(current.attributes == composition.attributes)
        #expect(current.text.utf16.elementsEqual(composition.text.utf16))
        #expect(window.view.hasMarkedText())
    }

    @Test("mismatched native source cannot authorize navigation")
    func linkOpeningNativeMismatch() throws
    {
        let window = try WritingTestWindow.linked()
        defer
        {
            window.close()
        }
        let before = window.storage
        let bridge = window.controller.bridge
        bridge.projecting = true
        window.view.textStorage?.setAttributedString(NSAttributedString(
            string: "Foreign text"
        ))
        bridge.projecting = false
        #expect(!window.controller.canResolveLink)
        #expect(bridge.textView(window.view,
            clickedOnLink: WritingScopeFixture.link, at: 1))
        #expect(window.storage == before)
    }
}
