import XCTest

@MainActor
enum WritingUIFormattingRoute
{
    case toolbar
    case formatMenu

    func chooseHeading(in app: XCUIApplication)
    {
        open("Paragraph Style", in: app)
        let heading = choice("Heading", group: "Paragraph Style", in: app)
        XCTAssertTrue(heading.wait(for: \.isHittable,
                                   toEqual: true, timeout: 5))
        let image = XCTAttachment(screenshot: app.screenshot())
        image.name = "Visible paragraph choices"
        image.lifetime = .keepAlways
        XCTContext.runActivity(named: "Inspect paragraph choices")
        {
            $0.add(image)
        }
        if self == .toolbar
        {
            heading.click()
        }
        else
        {
            app.typeKey(.rightArrow, modifierFlags: [])
            app.typeKey("h", modifierFlags: [])
            app.typeKey(.return, modifierFlags: [])
        }
        XCTAssertTrue(heading.wait(for: \.isHittable,
                                   toEqual: false, timeout: 5))
        if self == .formatMenu
        {
            let parent = app.menuBarItems["Format"].menuItems["Paragraph Style"]
            XCTAssertTrue(parent.wait(for: \.isHittable,
                                      toEqual: false, timeout: 5))
        }
        XCTAssertEqual(app.popUpButtons["FundamentalBlockStyle"].value
            as? String, "Heading")
    }

    func chooseList(_ title: String, in app: XCUIApplication)
    {
        open("List", in: app)
        let item = choice(title, group: "List", in: app)
        XCTAssertTrue(item.wait(for: \.isHittable, toEqual: true, timeout: 5))
        item.click()
        XCTAssertTrue(item.wait(for: \.isHittable, toEqual: false, timeout: 5))
    }

    func cancelMixedList(in app: XCUIApplication)
    {
        open("List", in: app)
        let title = self == .toolbar ? "Mixed" : "Numbered"
        let probe = choice(title, group: "List", in: app)
        XCTAssertTrue(probe.wait(for: \.isHittable, toEqual: true, timeout: 5))
        if self == .toolbar
        {
            XCTAssertFalse(probe.isEnabled)
        }
        else
        {
            XCTAssertTrue(probe.isEnabled)
        }
        app.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(probe.wait(for: \.isHittable, toEqual: false, timeout: 5))
        if self == .formatMenu
        {
            let parent = app.menuBarItems["Format"].menuItems["Paragraph Style"]
            if parent.isHittable
            {
                app.typeKey(.escape, modifierFlags: [])
            }
            XCTAssertTrue(parent.wait(for: \.isHittable,
                                      toEqual: false, timeout: 5))
        }
    }
}
