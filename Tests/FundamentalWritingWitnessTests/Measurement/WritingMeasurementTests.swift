import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

@MainActor
@Suite("Native manuscript writing measurements", .serialized, .enabled(
    if: ProcessInfo.processInfo.environment[
        "FUNDAMENTAL_WRITING_MEASURE"
    ] == "1"
))
struct WritingMeasurementTests
{
    @Test("native keys reach correct requested drawing at each document depth",
          arguments: WritingMeasurementLocation.allCases)
    func nativeDrawing(_ location: WritingMeasurementLocation) throws
    {
        let environment = ProcessInfo.processInfo.environment
        let count = try #require(Int(
            environment["FUNDAMENTAL_WRITING_PARAGRAPHS"] ?? "64"
        ))
        let corpus = try WritingMeasurementCorpus(
            paragraphs: count,
            semantic: environment["FUNDAMENTAL_WRITING_SEMANTIC"] == "1",
            scoped: environment["FUNDAMENTAL_WRITING_SCOPED"] == "1"
        )
        let seed = try #require(WritingDocumentSeed(document: corpus.document))
        let window = try WritingTestWindow(session: DocumentSession(
            state: seed.state, initiallySaved: true
        ))
        let recovery = try WritingMeasurementRecovery(window: window)
        defer
        {
            recovery.stop()
            window.close()
        }
        let projection = try #require(WritingProjection(window.session.state))
        let styles = window.styles
        let index = location.block(in: count)
        let offset = projection.map.spans[index].range.location
        window.select(offset, 1)
        window.controller.documentWindow.displayIfNeeded()
        #expect(window.controller.documentWindow.isVisible)
        let clock = ContinuousClock()
        var samples: [WritingMeasurementSample] = []
        for iteration in 0 ..< 35
        {
            try autoreleasepool
            {
                window.select(offset, 1)
                let text = iteration.isMultiple(of: 2) ? "x" : "y"
                let start = clock.now
                try window.key(text, code: text == "x" ? 7 : 16)
                let keyed = clock.now
                window.view.layoutSubtreeIfNeeded()
                window.controller.documentWindow.displayIfNeeded()
                let drawn = clock.now
                if iteration >= 5
                {
                    samples.append(WritingMeasurementSample(
                        key: start.duration(to: keyed),
                        drawing: keyed.duration(to: drawn)
                    ))
                }
                let current = try #require(WritingProjection(
                    window.session.state
                ))
                #expect(current.text.utf16.elementsEqual(window.view.string
                    .utf16))
                #expect(window.session.document.revision.value == iteration + 1)
                #expect(window.styles == styles)
                #expect((current.text as NSString).substring(with: NSRange(
                    location: offset, length: 1
                )) == text)
            }
        }
        try recovery.expectObserved(window)
        let report = WritingMeasurementReport(
            samples: samples, corpus: corpus, location: location
        )
        try report.emit()
        if let limit = environment["FUNDAMENTAL_WRITING_MEASURE_MAX_MS"]
            .flatMap(Double.init)
        {
            #expect(report.p95 <= limit)
        }
    }
}
