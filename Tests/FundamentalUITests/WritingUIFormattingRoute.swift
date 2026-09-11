import XCTest

@MainActor
enum WritingUIFormattingRoute
{
    case toolbar
    case toolbarOverflow
    case formatMenu

    func chooseHeading(in journey: WritingUIJourney)
    {
        chooseBlock("Heading 2", in: journey)
    }

    func chooseList(_ title: String, in journey: WritingUIJourney)
    {
        open("List", in: journey)
        let item = choice(title, group: "List", in: journey)
        XCTAssertTrue(item.wait(for: \.isHittable, toEqual: true, timeout: 5))
        item.click()
        XCTAssertTrue(item.wait(for: \.isHittable, toEqual: false, timeout: 5))
    }

    func cancelMixedList(in journey: WritingUIJourney)
    {
        let app = journey.app
        open("List", in: journey)
        let title = self == .toolbar ? "Mixed" : "Numbered"
        let probe = choice(title, group: "List", in: journey)
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
