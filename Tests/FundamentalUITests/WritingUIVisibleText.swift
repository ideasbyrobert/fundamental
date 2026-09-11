import Vision
import XCTest

@MainActor
enum WritingUIVisibleText
{
    static func expect(
        _ phrase: String, in screenshot: XCUIScreenshot, test: XCTestCase
    ) async throws
    {
        var request = RecognizeTextRequest(.revision3)
        request.usesLanguageCorrection = false
        request.recognitionLevel = .fast
        request.minimumTextHeightFraction = 0.01
        request.recognitionLanguages = [Locale.Language(identifier: "en-US")]
        let observations = try await request.perform(
            on: screenshot.pngRepresentation
        )
        let lines = observations.compactMap
        {
            $0.topCandidates(1).first?.string
        }
        let attachment = XCTAttachment(string: lines.joined(separator: "\n"))
        attachment.name = "Recognized editor text before typing"
        attachment.lifetime = .keepAlways
        test.add(attachment)
        _ = try XCTUnwrap(lines.first { $0.contains(phrase) },
                          "The insertion line must be visible before typing")
    }
}
