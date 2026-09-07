import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingAcceptanceTests
{
    @Test("mixed manuscript carets survive narrow and wide window resizing",
          arguments: WritingMeasurementLocation.allCases)
    func semanticGeometry(_ location: WritingMeasurementLocation) throws
    {
        let corpus = try WritingMeasurementCorpus(
            paragraphs: 1_000, semantic: true
        )
        let seed = try #require(WritingDocumentSeed(document: corpus.document))
        let window = try WritingTestWindow(session: DocumentSession(
            state: seed.state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        let index = location.block(in: 1_000)
        let range = window.controller.bridge.projection.map.spans[index].range
        window.select(range.location + range.length)
        window.view.scrollRangeToVisible(window.view.selectedRange())
        let state = window.session.state
        for width in [540.0, 1_150, 820]
        {
            window.controller.documentWindow.setContentSize(NSSize(
                width: width, height: 600
            ))
            window.view.layoutSubtreeIfNeeded()
            try WritingWindowGeometry.expectVisibleCaret(window)
            #expect(window.session.state == state)
            let container = try #require(window.view.textContainer)
            #expect(container.size.width <= 720)
            #expect(container.size.width >= 490)
            for marker in window.view.listMarkers(in: window.view.visibleRect)
            {
                #expect(marker.frame.minX >= 0)
                #expect(marker.frame.maxX < window.view.bounds.width)
            }
        }
    }
}
