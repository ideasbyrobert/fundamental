import AppKit
import XCTest

@MainActor
final class WritingUILinkBrowser
{
    let application: XCUIApplication
    let destination: URL
    let clipboard: WritingUIPasteboard
    var closed = false

    init(destination: URL, clipboard: WritingUIPasteboard) throws
    {
        self.destination = destination
        self.clipboard = clipboard
        let url = try XCTUnwrap(NSWorkspace.shared.urlForApplication(
            toOpen: destination
        ))
        application = XCUIApplication(url: url)
    }

    func confirmAndClose(test: XCTestCase) throws
    {
        XCTAssertTrue(application.wait(for: .runningForeground, timeout: 10))
        let heading = application.webViews.staticTexts["Link handoff confirmed"]
        XCTAssertTrue(heading.waitForExistence(timeout: 10))
        let attachment = XCTAttachment(screenshot: application.screenshot())
        attachment.name = "Default browser received the owned link"
        attachment.lifetime = .keepAlways
        test.add(attachment)
        _ = try XCTUnwrap(closeIfOwned() ? true : nil,
            "Refuse to close a browser tab with an unconfirmed URL")
        XCTAssertTrue(heading.waitForNonExistence(timeout: 5))
    }

    @discardableResult
    func closeIfOwned() -> Bool
    {
        guard !closed, application.state != .notRunning
        else
        {
            return closed
        }
        application.activate()
        clipboard.write("Awaiting the owned browser address")
        application.typeKey("l", modifierFlags: [.command])
        application.typeKey("c", modifierFlags: [.command])
        guard clipboard.copiedText(expected: destination.absoluteString)?
            .utf16.elementsEqual(destination.absoluteString.utf16) == true
        else
        {
            return false
        }
        application.typeKey("w", modifierFlags: [.command])
        closed = true
        return true
    }
}
