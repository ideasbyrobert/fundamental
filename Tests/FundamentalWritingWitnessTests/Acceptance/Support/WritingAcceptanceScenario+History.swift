import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingAcceptanceScenario
{
    func traverseHistory() throws
    {
        try history(.undo)
        try expect("Aé12 👋", 0, 7, revision: 6, generation: 8,
                   undo: 4, redo: 1)
        try history(.undo)
        try expect("Aé 👋", 2, revision: 7, generation: 9, undo: 3, redo: 2)
        try history(.redo)
        try expect("Aé12 👋", 4, revision: 8, generation: 10,
                   undo: 4, redo: 1)
    }

    func refuseThenBranch() throws
    {
        let before = window.storage
        window.view.insertNewline(nil)
        window.view.setMarkedText(
            "か", selectedRange: NSRange(location: 1, length: 0),
            replacementRange: NSRange(location: NSNotFound, length: 0)
        )
        #expect(window.storage == before)
        #expect(!window.view.hasMarkedText())
        try expect("Aé12 👋", 4, revision: 8, generation: 10,
                   undo: 4, redo: 1)
        try history(.undo)
        try expect("Aé 👋", 2, revision: 9, generation: 11, undo: 3, redo: 2)
        insert("!")
        try expect("Aé! 👋", 3, revision: 10, generation: 12, undo: 4)
    }
}
