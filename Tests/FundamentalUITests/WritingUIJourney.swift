import AppKit
import XCTest

@MainActor
struct WritingUIJourney
{
    let fixture: WritingUIFixture
    let test: XCTestCase
    let documentName: String
    let initialWindowName: String

    init(
        fixture: WritingUIFixture, test: XCTestCase,
        documentName: String = "Formatting.fun",
        initialWindowName: String = "Untitled"
    )
    {
        self.fixture = fixture
        self.test = test
        self.documentName = documentName
        self.initialWindowName = initialWindowName
    }

    var app: XCUIApplication { fixture.app }
    var window: XCUIElement
    {
        let named = app.windows[documentName]
        return named.exists ? named : app.windows[initialWindowName]
    }
    var editor: XCUIElement { window.textViews["Fundamental document"] }

    func step<Value>(_ name: String, _ action: () throws -> Value) rethrows
        -> Value
    {
        try XCTContext.runActivity(named: name)
        {
            activity in
            defer
            {
                if app.state != .notRunning
                {
                    let data = Data(app.debugDescription.utf8)
                    let text = XCTAttachment(data: data,
                        uniformTypeIdentifier: "public.utf8-plain-text")
                    text.name = name + " accessibility"
                    text.lifetime = .keepAlways
                    activity.add(text)
                    let image = XCTAttachment(screenshot: app.screenshot())
                    image.name = name
                    image.lifetime = .keepAlways
                    activity.add(image)
                }
            }
            return try action()
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
