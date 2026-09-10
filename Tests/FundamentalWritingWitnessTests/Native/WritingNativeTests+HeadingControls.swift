import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("heading controls retain traits scopes selection and canonical undo",
          arguments: SemanticHeadingLevel.allCases, [false, true])
    func headingControlsPreserveMeaning(
        _ level: SemanticHeadingLevel, toolbar: Bool
    ) throws
    {
        let runs = try WritingHeadingFixture.runs()
        let source = try WritingTestDocument(blocks: [
            .heading(.title(TitleSemanticHeading(runs: runs))),
            .listItem(SemanticListItem(kind: .numbered, runs: runs))
        ])
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        let text = window.view.string
        let selection = NSRange(location: 0, length: text.utf16.count)
        window.select(selection.location, selection.length)
        let before = window.storage
        let title = "Heading \(level.rawValue)"
        let item = try window.formatChoice(title, group: "Paragraph Style")
        #expect(window.controller.formatting.block.selectedItem?.title ==
            "Mixed")
        #expect(window.controller.validateUserInterfaceItem(item))
        #expect(item.state == .off && window.storage == before)
        let expected = SemanticBlock.heading(.section(SectionSemanticHeading(
            runs: runs, level: level
        )))
        let style = try #require(CanonicalBlockStyle(expected))
        if toolbar
        {
            try window.choose(style)
        }
        else
        {
            try window.performFormat(item)
        }
        let after = window.session.document.content
        #expect(after.blocks.map(\.block) == [expected, expected])
        #expect(after.blocks.map(\.blockID) ==
            source.state.snapshot.document.content.blocks.map(\.blockID))
        try window.expect(text, selection: selection)
        #expect(window.controller.documentWindow.firstResponder === window.view)
        #expect(window.controller.formatting.block.selectedItem?.title == title)
        #expect(window.controller.validateUserInterfaceItem(item))
        #expect(item.state == .on)
        #expect(window.session.history.undo.count == 1)
        let unchanged = window.storage
        try window.performFormat(item)
        #expect(window.storage == unchanged)
        #expect(try window.markerLabels().isEmpty)
        try window.key("X", code: 7)
        try window.expect("X", selection: NSRange(location: 1, length: 0))
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == after)
        try window.expect(text, selection: selection)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            source.state.snapshot.document.content)
        #expect(!window.session.isDirty)
        window.view.redoCanonicalEdit(nil)
        #expect(window.session.document.content == after)
        try window.expect(text, selection: selection)
    }
}
