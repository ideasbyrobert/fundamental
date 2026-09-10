import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("consecutive bullets keep a marker on each actual paragraph",
          arguments: [NSAppearance.Name.aqua, .darkAqua])
    func consecutiveBullets(appearance: NSAppearance.Name) throws
    {
        let window = try WritingTestWindow(
            styles: [.body, .body, .body, .body, .body],
            texts: ["Before", "First", "Second", "Third", "After"]
        )
        defer
        {
            window.close()
        }
        window.controller.documentWindow.appearance = NSAppearance(
            named: appearance
        )
        window.select(7, 18)
        try window.choose(.bulleted)
        #expect(window.styles == [
            .body, .bulleted, .bulleted, .bulleted, .body
        ])
        #expect(try window.markerLabels() == ["•", "•", "•"])
        let overlay = try #require(window.view.listOverlay)
        defer
        {
            overlay.isHidden = false
        }
        let before = window.storage
        overlay.isHidden = true
        let background = try WritingWindowCapture.capture(window)
        overlay.isHidden = false
        let bitmap = try WritingWindowCapture.capture(window)
        #expect(window.storage == before)
        for marker in window.view.listMarkers(in: window.view.visibleRect)
        {
            #expect(try WritingWindowCapture.markerInk(
                marker.frame, in: window, bitmap: bitmap, background: background
            ) > 3)
        }
        try WritingWindowCapture.export(bitmap,
            name: "consecutive-bullets-" + appearance.rawValue)
        window.view.undoCanonicalEdit(nil)
        #expect(try window.markerLabels().isEmpty)
        window.view.redoCanonicalEdit(nil)
        #expect(try window.markerLabels() == ["•", "•", "•"])
    }
}
