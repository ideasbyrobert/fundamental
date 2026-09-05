import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingAcceptanceScenario
{
    func beginAndType() throws
    {
        try expect("", 0, revision: 0, generation: 0, undo: 0)
        try window.key("A", code: 0)
        try expect("A", 1, revision: 1, generation: 1, undo: 1)
        insert("e\u{301} 👋")
        try expect("Ae\u{301} 👋", 6, revision: 2, generation: 2, undo: 2)
    }

    func replaceAndPaste() throws
    {
        window.select(1, 2)
        try expect("Ae\u{301} 👋", 1, 2, revision: 2, generation: 3, undo: 2)
        insert("é")
        try expect("Aé 👋", 2, revision: 3, generation: 4, undo: 3)
        #expect(pasteboard.setString("12", forType: .string))
        window.view.paste(pasteboard)
        try expect("Aé12 👋", 4, revision: 4, generation: 5, undo: 4)
    }

    func copyAndDelete() throws
    {
        window.view.selectAll(nil)
        try expect("Aé12 👋", 0, 7, revision: 4, generation: 6, undo: 4)
        let before = window.storage
        window.view.copy(pasteboard)
        let copied = try #require(pasteboard.string(forType: .string))
        #expect(copied.utf16.elementsEqual("Aé12 👋".utf16))
        #expect(window.storage == before)
        window.view.deleteBackward(nil)
        try expect("", 0, revision: 5, generation: 7, undo: 5)
    }
}
