import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test
    func textKitOneCannotAdvanceTextSelectionOrHistory() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.view.insertText("X", replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        let before = window.storage
        let legacy = NSTextView(usingTextLayoutManager: false)
        legacy.string = "XAB"
        let bridge = window.controller.bridge
        #expect(!bridge.project(in: legacy))
        let allowed = bridge.textView(
            legacy,
            shouldChangeTextInRanges: [
                NSValue(range: NSRange(location: 1, length: 0))
            ],
            replacementStrings: ["Y"]
        )
        #expect(!allowed)
        legacy.setSelectedRange(NSRange(location: 0, length: 1))
        bridge.textViewDidChangeSelection(Notification(
            name: NSTextView.didChangeSelectionNotification, object: legacy
        ))
        #expect(bridge.move(.undo, in: legacy) == .refused(.invalidCommand))
        #expect(window.storage == before)
        try window.expect("XAB", selection: NSRange(location: 1, length: 0))
    }

    @Test
    func nativeOnlyMutationIsRepairedBeforeFollowingInput() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        let before = window.storage
        window.view.string = "POISON"
        #expect(window.storage == before)
        try window.expect("AB", selection: NSRange(location: 0, length: 0))
        window.view.insertText("X", replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        try window.expect("XAB", selection: NSRange(location: 1, length: 0))
        #expect(window.session.history.undo.count == 1)
    }

    @Test
    func poisonedBufferProposalIsRefusedBeforeCanonicalMutation() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        let before = window.storage
        let bridge = window.controller.bridge
        window.view.delegate = nil
        window.view.string = "POISON"
        window.view.delegate = bridge
        let allowed = bridge.textView(
            window.view,
            shouldChangeTextInRanges: [
                NSValue(range: NSRange(location: 0, length: 0))
            ],
            replacementStrings: ["X"]
        )
        #expect(!allowed)
        #expect(window.storage == before)
        try window.expect("AB", selection: NSRange(location: 0, length: 0))
    }
}
