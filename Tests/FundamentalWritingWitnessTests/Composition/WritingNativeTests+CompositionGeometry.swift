import AppKit
import FundamentalDocument
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("deep manuscript preedit exposes a visible native input caret")
    func geometry() throws
    {
        let corpus = try WritingMeasurementCorpus(paragraphs: 1_000)
        let seed = try #require(WritingDocumentSeed(document: corpus.document))
        let window = try WritingTestWindow(session: DocumentSession(
            state: seed.state, initiallySaved: true
        ))
        defer
        {
            window.view.cancelOperation(nil)
            window.close()
        }
        let projection = window.controller.bridge.projection
        let offset = try #require(projection.map.spans.last).range.location
        window.select(offset)
        window.mark("かんじ")
        window.view.scrollRangeToVisible(window.view.markedRange())
        #expect(window.view.hasMarkedText())
        try WritingWindowGeometry.expectVisibleCaret(window)
        window.controller.documentWindow.setContentSize(NSSize(
            width: 1_200, height: 680
        ))
        try WritingWindowGeometry.expectVisibleCaret(window)
        #expect(window.session.document == corpus.document)
        #expect(!window.session.isDirty)
        #expect(window.view.textLayoutManager != nil)
    }
}
