import AppKit
import Vision
import XCTest

extension WritingUIVisibleText
{
    static func height(
        of phrase: String, in screenshot: XCUIScreenshot, test: XCTestCase
    ) async throws -> CGFloat
    {
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = phrase + " before measuring rendered height"
        attachment.lifetime = .keepAlways
        test.add(attachment)
        let lines = try await observations(in: screenshot)
        let recognized = XCTAttachment(string: lines.compactMap
            { $0.topCandidates(1).first?.string }.joined(separator: "\n"))
        recognized.name = "Recognized text for " + phrase
        recognized.lifetime = .keepAlways
        test.add(recognized)
        let line = try XCTUnwrap(lines.first
        {
            $0.topCandidates(1).first?.string.contains(phrase) == true
        }, "The expected writing must be rendered in the screenshot")
        let bitmap = try XCTUnwrap(NSBitmapImageRep(
            data: screenshot.pngRepresentation
        ))
        let height = line.boundingBox.height * CGFloat(bitmap.pixelsHigh)
        print("\(phrase) rendered height: \(height) pixels")
        return height
    }
}
