import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("list markers are drawn once and numbering restarts at interruptions",
          arguments: [NSAppearance.Name.aqua, .darkAqua])
    func semanticMarkers(_ appearance: NSAppearance.Name) throws
    {
        let window = try WritingTestWindow(
            styles: [.bulleted, .numbered, .numbered, .body, .numbered],
            texts: ["Bullet", "First", "Second", "Break", "Restart"]
        )
        defer
        {
            window.close()
        }
        window.controller.documentWindow.appearance =
            NSAppearance(named: appearance)
        #expect(try window.markerLabels() == ["•", "1.", "2.", "1."])
        #expect(window.view.string == "Bullet\nFirst\nSecond\nBreak\nRestart")
        #expect(!window.view.string.contains("•"))
        let markers = window.view.listMarkers(in: window.view.visibleRect)
        for marker in markers
        {
            #expect(marker.frame.width > 0 && marker.frame.height > 0)
            #expect(window.view.visibleRect.contains(marker.frame))
        }
        let bitmap = try WritingWindowCapture.capture(window)
        #expect(try WritingWindowCapture.contrastingSamples(bitmap) > 100)
        try WritingWindowCapture.export(bitmap,
            name: "semantic-markers-" + appearance.rawValue)
    }

    @Test("wrapped list text and a final empty item each retain one marker")
    func wrappedAndEmptyMarkers() throws
    {
        let window = try WritingTestWindow(
            styles: [.numbered, .numbered],
            texts: [String(repeating: "A wrapping list item. ", count: 7), ""]
        )
        defer
        {
            window.close()
        }
        #expect(try window.markerLabels() == ["1.", "2."])
        window.selectBlock(0)
        try window.choose(.body)
        #expect(try window.markerLabels() == ["1."])
        window.view.undoCanonicalEdit(nil)
        #expect(try window.markerLabels() == ["1.", "2."])
    }

    @Test("semantic typography survives rebuilding a poisoned native buffer")
    func semanticTypography() throws
    {
        let window = try WritingTestWindow(
            styles: [.title, .heading, .subheading, .body],
            texts: ["A title", "A heading", "A subheading", "A paragraph"]
        )
        defer
        {
            window.close()
        }
        let before = window.storage
        window.view.string = "Poison"
        #expect(window.storage == before)
        let storage = try #require(window.view.textStorage)
        let sizes = window.controller.bridge.projection.map.spans.map
        {
            (storage.attribute(.font, at: $0.range.location,
                               effectiveRange: nil) as? NSFont)?.pointSize
        }
        #expect(sizes == [34, 26, 22, 20])
        let bitmap = try WritingWindowCapture.capture(window)
        try WritingWindowCapture.export(bitmap, name: "semantic-typography")
    }
}
