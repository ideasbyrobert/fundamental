import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test
    func multipleSelectionsNeverReplaceCanonicalSelection() throws
    {
        let window = try WritingTestWindow("ABCD")
        defer
        {
            window.close()
        }
        let before = window.storage
        window.view.setSelectedRanges([
            NSValue(range: NSRange(location: 0, length: 1)),
            NSValue(range: NSRange(location: 2, length: 1))
        ], affinity: .downstream, stillSelecting: false)
        #expect(window.storage == before)
        #expect(window.view.selectedRanges.count == 1)
        try window.expect("ABCD", selection: NSRange(location: 0, length: 0))
    }

    @Test
    func surrogateInteriorProposalRefusesWithoutHistory() throws
    {
        let window = try WritingTestWindow("👋")
        defer
        {
            window.close()
        }
        let before = window.storage
        let allowed = window.controller.bridge.textView(
            window.view,
            shouldChangeTextInRanges: [
                NSValue(range: NSRange(location: 1, length: 1))
            ],
            replacementStrings: [""]
        )
        #expect(!allowed)
        #expect(window.storage == before)
        try window.expect("👋", selection: NSRange(location: 0, length: 0))
    }

    @Test
    func attributeOnlyAndRichPasteProposalsRefuse() throws
    {
        let window = try WritingTestWindow("AB")
        let board = NSPasteboard.withUniqueName()
        defer
        {
            board.releaseGlobally()
            window.close()
        }
        let before = window.storage
        let allowed = window.controller.bridge.textView(
            window.view,
            shouldChangeTextInRanges: [
                NSValue(range: NSRange(location: 0, length: 1))
            ],
            replacementStrings: nil
        )
        #expect(!allowed)
        #expect(!window.view.readSelection(from: board, type: .rtf))
        window.view.pasteAsRichText(board)
        #expect(window.storage == before)
        try window.expect("AB", selection: NSRange(location: 0, length: 0))
    }
}
