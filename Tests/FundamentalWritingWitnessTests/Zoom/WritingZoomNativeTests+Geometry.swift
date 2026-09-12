import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingZoomNativeTests
{
    @Test("zoom reflows mixed writing and keeps distant carets visible",
          arguments: [360.0, 540.0, 820.0, 1150.0])
    func geometry(_ width: Double) throws
    {
        let text = "A line of writing with Мир, e\u{301} and 👨‍👩‍👧‍👦. "
        let group: [SemanticBlock] = [
            CanonicalBlockStyle.title.semanticBlock(runs: [
                SemanticRun(text: "A heading")
            ]),
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: String(repeating: text, count: 3))
            ])),
            .listItem(SemanticListItem(kind: .numbered, runs: [
                SemanticRun(text: text)
            ])),
            try WritingCodeFixture.block("\tlet message = \"Hello, Мир\"\n",
                                          tagged: true)
        ]
        let source = try WritingTestDocument(blocks:
            Array(repeating: group, count: 20).flatMap { $0 }
        )
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state, initiallySaved: true
        ), size: NSSize(width: width, height: 500))
        defer { window.close() }
        window.select(window.view.string.utf16.count)
        let original = window.storage
        var previousHeight: CGFloat = 0
        for percentage in [50, 100, 200]
        {
            #expect(window.controller.applyZoom(WritingZoom(percentage)))
            #expect(window.storage == original)
            #expect(!window.session.isDirty)
            #expect(!window.controller.scrollView.hasHorizontalScroller)
            let clip = window.controller.scrollView.contentView
            #expect(window.view.frame.width == clip.bounds.width)
            try WritingWindowGeometry.expectVisibleCaret(window,
                context: "\(width) points at \(percentage) percent")
            let layout = try #require(window.view.textLayoutManager)
            let height = layout.usageBoundsForTextContainer.height
            #expect(height > previousHeight)
            previousHeight = height
            let container = try #require(window.view.textContainer)
            #expect(container.widthTracksTextView)
            #expect(layout.usageBoundsForTextContainer.width <=
                container.size.width + 1)
        }
        window.controller.documentWindow.setContentSize(
            NSSize(width: 360, height: 500)
        )
        window.controller.updateWritingGeometry()
        try WritingWindowGeometry.expectVisibleCaret(window,
            context: "Resize after zoom")
        #expect(window.storage == original)
    }
}
