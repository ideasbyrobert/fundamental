import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("consecutive bullets keep a marker on each actual paragraph")
    func consecutiveBullets() throws
    {
        let window = try WritingTestWindow(
            styles: [.body, .body, .body, .body, .body],
            texts: ["Before", "First", "Second", "Third", "After"]
        )
        defer
        {
            window.close()
        }
        window.select(7, 18)
        try window.choose(.bulleted)
        #expect(window.styles == [
            .body, .bulleted, .bulleted, .bulleted, .body
        ])
        #expect(try window.markerLabels() == ["•", "•", "•"])
        let bitmap = try WritingWindowCapture.capture(window)
        for marker in window.view.listMarkers(in: window.view.visibleRect)
        {
            #expect(try WritingWindowCapture.markerInk(
                marker.frame, in: window, bitmap: bitmap
            ) > 3)
        }
        try WritingWindowCapture.export(bitmap, name: "consecutive-bullets")
        window.view.undoCanonicalEdit(nil)
        #expect(try window.markerLabels().isEmpty)
        window.view.redoCanonicalEdit(nil)
        #expect(try window.markerLabels() == ["•", "•", "•"])
    }
}
