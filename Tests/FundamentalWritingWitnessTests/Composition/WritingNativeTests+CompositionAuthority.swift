import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("stale composition cannot overwrite a newer canonical edit")
    func stale() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.mark("draft")
        let external = try #require(WritingTextProposal(
            ranges: [NSRange(location: 0, length: 0)], replacements: ["X"],
            in: window.controller.bridge.projection
        ))
        window.session.submit(external.command)
        let before = window.storage
        window.commit("accepted")
        #expect(window.storage == before)
        #expect(!window.view.hasMarkedText())
        try window.expect("XAB", selection: NSRange(location: 1, length: 0))
    }

    @Test("unexpected native spelling cannot be accepted as composition")
    func poisoned() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        let before = window.storage
        window.mark("draft")
        window.view.delegate = nil
        window.view.string = "poison"
        window.view.delegate = window.controller.bridge
        window.commit("accepted")
        #expect(window.storage == before)
        #expect(!window.view.hasMarkedText())
        try window.expect("AB", selection: NSRange(location: 0, length: 0))
    }

    @Test("a reconstructed view receives no provisional native content")
    func reconstructed() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.view.cancelOperation(nil)
            window.close()
        }
        window.select(1)
        let before = window.storage
        window.mark("draft")
        let replacement = WritingTextView(usingTextLayoutManager: true)
        let bridge = try #require(WritingNativeBridge(session: window.session))
        #expect(WritingTextConfiguration.apply(to: replacement))
        replacement.delegate = bridge
        #expect(bridge.project(in: replacement))
        #expect(window.storage == before)
        #expect(replacement.string == "AB")
        #expect(!replacement.hasMarkedText())
        #expect(replacement.selectedRange() == NSRange(location: 1, length: 0))
    }
}
