import AppKit
import XCTest

extension WritingUIJourney
{
    func useAppearance(_ appearance: XCUIDevice.Appearance)
    {
        WritingUIAppearance.use(appearance, test: test)
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
