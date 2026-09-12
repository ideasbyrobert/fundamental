import AppKit
import XCTest

extension WritingUITests
{
    func testVoiceOverWritingAndKeyboardFind() throws
    {
        guard #available(macOS 27.0, *)
        else
        {
            throw XCTSkip("VoiceOver speech service requires macOS 27")
        }
        let voiceOver = XCUIDevice.shared.voiceOverService
        try XCTSkipIf(voiceOver.isEnabled,
                      "Preserve an existing VoiceOver session")
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self)
        let app = fixture.app
        XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
        journey.editor.click()
        journey.paste("Marigold writing\nSecond paragraph")
        app.typeKey(.upArrow, modifierFlags: [.command])
        addTeardownBlock
        {
            @MainActor in
            try voiceOver.disable()
            XCTAssertFalse(voiceOver.isEnabled)
            XCTAssertFalse(NSWorkspace.shared.isVoiceOverEnabled)
        }
        let location = try XCTUnwrap(NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: "com.apple.VoiceOver"
        ))
        XCTAssertTrue(NSWorkspace.shared.open(location))
        let introduction = XCUIApplication(
            bundleIdentifier: "com.apple.VoiceOverQuickstart"
        )
        let start = introduction.windows.firstMatch.buttons["Use VoiceOver"]
        if start.waitForExistence(timeout: 5)
        {
            introduction.activate()
            start.click()
        }
        try voiceOver.enable()
        XCTAssertTrue(voiceOver.isEnabled)
        app.activate()
        journey.editor.click()
        app.typeKey(.upArrow, modifierFlags: [.command])
        app.typeKey(.rightArrow, modifierFlags: [.command, .shift])
        var spoken = try voiceOver.currentSpeech().utterance
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        while !spoken.contains("Marigold writing") &&
              ContinuousClock.now < deadline
        {
            Thread.sleep(forTimeInterval: 0.1)
            spoken = try voiceOver.currentSpeech().utterance
        }
        let speech = XCTAttachment(string: spoken)
        speech.name = "VoiceOver spoken writing surface"
        speech.lifetime = .keepAlways
        add(speech)
        XCTAssertTrue(spoken.contains("Marigold writing"), spoken)
        let image = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        image.name = "VoiceOver and native writing"
        image.lifetime = .keepAlways
        add(image)
        journey.find("writing")
        journey.expectMatches("1 of 1")
        app.typeKey(.escape, modifierFlags: [])
        journey.expectSelection("writing")
        try journey.expectText("Marigold writing\nSecond paragraph")
    }
}
