import Testing

@testable import FundamentalDocument

extension DocumentHistorySequenceTests
{
    @Test
    func historyRestoresSelectionAcrossInterveningSelectionChanges() throws
    {
        let driver = SessionHistoryTestDriver(
            try SessionTestDocument(texts: ["ABCD"])
        )
        let selected = try driver.select(3, 1)
        let insertion = try #require(SemanticInsertion(
            text: "X",
            attributes: .direct(traits: [])
        ))
        let replacement = try #require(SemanticTextReplacement(
            range: selected.selection.range,
            insertion: insertion
        ))
        try driver.edit(.text(.replacement(replacement)))
        try driver.expect("AXD", revision: 9, generation: 5)
        let undone = try driver.move(.undo)
        try driver.expect("ABCD", revision: 10, generation: 6)
        #expect(undone.selection.range.start.utf16Offset.value == 3)
        #expect(undone.selection.range.end.utf16Offset.value == 1)
        let history = driver.session.history
        try driver.select(0, 0)
        #expect(driver.session.history == history)
        let redone = try driver.move(.redo)
        try driver.expect("AXD", revision: 11, generation: 8)
        #expect(redone.selection.isCollapsed)
        #expect(redone.selection.range.start.utf16Offset.value == 2)
        #expect(selected.selection.range.revision.value == 8)
    }
}
