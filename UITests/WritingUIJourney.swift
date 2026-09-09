import AppKit
import XCTest

@MainActor
struct WritingUIJourney
{
    let fixture: WritingUIFixture
    let test: XCTestCase

    var app: XCUIApplication { fixture.app }
    var editor: XCUIElement { app.textViews["Fundamental document"] }

    func step(_ name: String, _ action: () throws -> Void) rethrows
    {
        try XCTContext.runActivity(named: name)
        {
            activity in
            defer
            {
                let text = XCTAttachment(string: app.debugDescription)
                text.name = name + " accessibility"
                text.lifetime = .keepAlways
                activity.add(text)
                let image = XCTAttachment(screenshot: app.screenshot())
                image.name = name
                image.lifetime = .keepAlways
                activity.add(image)
            }
            try action()
        }
    }

    func expectText(_ text: String) throws
    {
        let actual = try XCTUnwrap(editor.value as? String)
        XCTAssertEqual(Array(actual.utf16), Array(text.utf16))
    }

    func expectSelection(_ text: String)
    {
        fixture.clipboard.write("Selection has not been copied")
        app.typeKey("c", modifierFlags: [.command])
        XCTAssertEqual(fixture.clipboard.copiedText(expected: text).map
            { Array($0.utf16) }, Array(text.utf16))
    }

    func paste(_ text: String)
    {
        fixture.clipboard.write(text)
        app.typeKey("v", modifierFlags: [.command])
    }

    func chooseList(_ title: String)
    {
        app.menuButtons["FundamentalListStyle"].click()
        app.menuItems[title].click()
    }

    func wait(_ message: String, until condition: () -> Bool)
    {
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        while ContinuousClock.now < deadline
        {
            if condition()
            {
                return
            }
            Thread.sleep(forTimeInterval: 0.05)
        }
        XCTAssertTrue(condition(), message)
    }
}
