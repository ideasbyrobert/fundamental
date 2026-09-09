import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("list removal preserves exact headings selection and typing focus")
    func noListPreservesHeadings() throws
    {
        let headings = SemanticHeadingLevel.allCases.map
        {
            SemanticBlock.heading(.section(SectionSemanticHeading(
                runs: [SemanticRun(text: "Heading \($0.rawValue)")], level: $0
            )))
        }
        let item = SemanticBlock.listItem(SemanticListItem(
            kind: .numbered, runs: [SemanticRun(text: "A😀e\u{301}")]
        ))
        let window = try WritingTestWindow(session: DocumentSession(
            state: WritingTestDocument(blocks: headings + [item]).state,
            initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        let text = window.view.string
        let selection = NSRange(location: 0, length: text.utf16.count)
        window.select(selection.location, selection.length)
        let before = window.session.document.content
        #expect(window.controller.formatting.list.selectedItem?.title ==
            "Mixed")
        try window.chooseNoList()
        #expect(Array(window.session.document.content.blocks.prefix(6)) ==
            Array(before.blocks.prefix(6)))
        #expect(window.styles.last == .body)
        #expect(window.session.history.undo.count == 1)
        try window.expect(text, selection: selection)
        #expect(window.controller.documentWindow.firstResponder === window.view)
        #expect(try window.markerLabels().isEmpty)
        let removed = window.session.document.content
        try window.key("X", code: 7)
        try window.expect("X", selection: NSRange(location: 1, length: 0))
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == removed)
        try window.expect(text, selection: selection)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == before)
        #expect(!window.session.isDirty)
        #expect(try window.markerLabels() == ["1."])
    }

    @Test("reselecting a list choice preserves history and saved state")
    func unchangedListChoice() throws
    {
        for style in [CanonicalBlockStyle.body, .bulleted, .numbered]
        {
            let window = try WritingTestWindow(styles: [style], texts: ["A"])
            defer
            {
                window.close()
            }
            let before = window.session.current
            if style == .body
            {
                try window.chooseNoList()
            }
            else
            {
                try window.choose(style)
            }
            #expect(window.session.current == before)
            #expect(!window.session.isDirty)
            let list = window.controller.formatting.list
            #expect(list.title == "List")
            #expect(list.selectedItem?.state == .on)
            #expect(list.item(withTitle: "Mixed")?.isHidden == true)
            #expect(window.controller.documentWindow.firstResponder ===
                window.view)
        }
    }
}
