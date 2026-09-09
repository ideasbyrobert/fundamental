import AppKit
import XCTest

extension WritingUIJourney
{
    func useAppearance(_ appearance: XCUIDevice.Appearance)
    {
        let prior = XCUIDevice.shared.appearance
        test.addTeardownBlock
        {
            await MainActor.run
            {
                XCUIDevice.shared.appearance = prior
                XCTAssertEqual(XCUIDevice.shared.appearance, prior)
                print("Restored device appearance: \(prior.rawValue)")
            }
        }
        print("Initial device appearance: \(prior.rawValue)")
        XCUIDevice.shared.appearance = appearance
        XCTAssertEqual(XCUIDevice.shared.appearance, appearance)
    }

    func expectAppearance(_ appearance: XCUIDevice.Appearance) throws
        -> XCUIScreenshot
    {
        let viewport = window.scrollViews.firstMatch
        let screenshot = viewport.screenshot()
        let bitmap = try XCTUnwrap(NSBitmapImageRep(
            data: screenshot.pngRepresentation
        ))
        let scale = CGFloat(bitmap.pixelsWide) / viewport.frame.width
        let pixel = try XCTUnwrap(bitmap.colorAt(
            x: Int(12 * scale), y: bitmap.pixelsHigh / 2
        )?.usingColorSpace(.deviceRGB))
        let lightness = (pixel.redComponent + pixel.greenComponent +
            pixel.blueComponent) / 3
        XCTAssertTrue(appearance == .light ? lightness > 0.8 : lightness < 0.25)
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Editor appearance \(appearance.rawValue)"
        attachment.lifetime = .keepAlways
        test.add(attachment)
        return screenshot
    }
}
