import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test
    func selectionChangesOnlyGeneration() throws
    {
        let window = try WritingTestWindow("ABCD")
        defer
        {
            window.close()
        }
        window.select(1, 2)
        try window.expect("ABCD", selection: NSRange(location: 1, length: 2))
        #expect(window.session.state.snapshot.generation.value == 4)
        #expect(window.session.state.snapshot.document.revision.value == 8)
        #expect(window.session.history.undo.isEmpty)
        let before = window.storage
        window.select(1, 2)
        #expect(window.storage == before)
    }

    @Test
    func rebuildingNativeProjectionPreservesCompleteSession() throws
    {
        let window = try WritingTestWindow()
        defer
        {
            window.close()
        }
        window.view.insertText("ABC", replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        window.select(1, 1)
        let before = window.storage
        let replacement = WritingTextView(usingTextLayoutManager: true)
        let bridge = try #require(WritingNativeBridge(session: window.session))
        #expect(WritingTextConfiguration.apply(to: replacement))
        replacement.delegate = bridge
        #expect(bridge.project(in: replacement))
        #expect(window.storage == before)
        #expect(replacement.string == "ABC")
        #expect(replacement.selectedRange() == NSRange(location: 1, length: 1))
        #expect(replacement.textLayoutManager != nil)
    }

    @Test
    func staleNativeProposalReprojectsWithoutRetargeting() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        let old = window.controller.bridge.projection
        let external = try #require(WritingTextProposal(
            ranges: [NSRange(location: 0, length: 0)],
            replacements: ["X"],
            in: old
        ))
        window.session.submit(external.command)
        let before = window.storage
        window.view.insertText("Y", replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        #expect(window.storage == before)
        try window.expect("XAB", selection: NSRange(location: 1, length: 0))
    }
}
