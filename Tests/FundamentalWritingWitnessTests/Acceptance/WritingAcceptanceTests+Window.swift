import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingAcceptanceTests
{
    @Test(arguments: [NSAppearance.Name.aqua, .darkAqua], [820.0, 1200.0])
    func nativeWindowDrawsExactContentAtBothMeasures(
        appearance: NSAppearance.Name,
        width: Double
    ) throws
    {
        let text = "Fundamental begins with a single paragraph. " +
            "English words, numbers 0123456789, and Unicode—café, e\u{301}, " +
            "👩🏽‍💻—keep their exact spelling. What is, is. " +
            "What is not, is not."
        let source = try WritingTestDocument(text)
        let session = DocumentSession(state: source.state)
        let window = try WritingTestWindow(
            session: session, size: NSSize(width: width, height: 600)
        )
        defer
        {
            window.close()
        }
        window.controller.documentWindow.appearance =
            NSAppearance(named: appearance)
        let before = window.storage
        let bitmap = try WritingWindowCapture.capture(window)
        try WritingWindowGeometry.expect(window, width: width)
        #expect(bitmap.pixelsWide >= Int(width))
        #expect(bitmap.pixelsHigh >= 600)
        #expect(try WritingWindowCapture.contrastingSamples(bitmap) > 100)
        try WritingWindowCapture.export(bitmap,
            name: appearance.rawValue + "-" + String(Int(width)))
        let opposite = width == 820 ? 1200.0 : 820.0
        window.controller.documentWindow.setContentSize(NSSize(
            width: opposite, height: 600
        ))
        _ = try WritingWindowCapture.capture(window)
        try WritingWindowGeometry.expect(window, width: opposite)
        #expect(window.storage == before)
        try window.expect(text, selection: NSRange(location: 0, length: 0))
    }

    @Test
    func nativeAccessibilityReportsExactTextAndSelection() throws
    {
        let window = try WritingTestWindow("Ae\u{301}👋")
        defer
        {
            window.close()
        }
        window.select(1, 2)
        _ = try WritingWindowCapture.capture(window)
        let value = try #require(window.view.accessibilityValue())
        #expect(value.utf16.elementsEqual("Ae\u{301}👋".utf16))
        #expect(window.view.accessibilityNumberOfCharacters() == 5)
        #expect(window.view.accessibilitySelectedTextRange() ==
            NSRange(location: 1, length: 2))
        let selected = try #require(window.view.accessibilitySelectedText())
        #expect(selected.utf16.elementsEqual("e\u{301}".utf16))
        #expect(window.view.accessibilityFrame().width > 0)
        #expect(window.view.accessibilityLabel() == "Fundamental document")
    }
}
