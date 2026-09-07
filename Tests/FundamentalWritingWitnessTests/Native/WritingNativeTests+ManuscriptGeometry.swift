import AppKit
import FundamentalDocument
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("manuscript carets stay visible through deep navigation and resize")
    func manuscriptGeometry() throws
    {
        let corpus = try WritingMeasurementCorpus(paragraphs: 1_000)
        let seed = try #require(WritingDocumentSeed(document: corpus.document))
        let window = try WritingTestWindow(session: DocumentSession(
            state: seed.state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        let projection = try #require(WritingProjection(window.session.state))
        for index in [0, 500, 999]
        {
            let offset = projection.map.spans[index].range.location
            window.select(offset)
            window.view.scrollRangeToVisible(window.view.selectedRange())
            try WritingWindowGeometry.expectVisibleCaret(window)
            let point = window.session.state
            #expect(WritingProjection(point)?.selection.location == offset)
            #expect(!window.session.isDirty)
            if index > 0
            {
                #expect(window.controller.scrollView
                    .documentVisibleRect.origin.y > 0)
            }
        }
        window.controller.documentWindow.setContentSize(NSSize(
            width: 1_200, height: 680
        ))
        try WritingWindowGeometry.expectVisibleCaret(window)
        window.controller.documentWindow.setContentSize(NSSize(
            width: 820, height: 600
        ))
        try WritingWindowGeometry.expectVisibleCaret(window)
        #expect(window.session.document == corpus.document)
        #expect(window.view.textLayoutManager != nil)
    }
}
