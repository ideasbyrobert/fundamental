import XCTest

extension WritingUIFormattingRoute
{
    func chooseBlock(_ title: String, in journey: WritingUIJourney)
    {
        open("Paragraph Style", in: journey)
        let item = choice(title, group: "Paragraph Style", in: journey)
        XCTAssertTrue(item.wait(for: \.isHittable, toEqual: true, timeout: 5))
        journey.step("Inspect paragraph choices: " + title)
        {
            XCTAssertTrue(item.isEnabled)
        }
        if self == .formatMenu
        {
            journey.app.typeKey(.rightArrow, modifierFlags: [])
            journey.app.typeKey(String(title.prefix(1)), modifierFlags: [])
            let headings = (1 ... 6).map { "Heading \($0)" }
            for _ in 0 ..< (headings.firstIndex(of: title) ?? 0)
            {
                journey.app.typeKey(.downArrow, modifierFlags: [])
            }
            journey.app.typeKey(.return, modifierFlags: [])
        }
        else
        {
            item.click()
        }
        XCTAssertTrue(item.wait(for: \.isHittable, toEqual: false, timeout: 5))
        if self == .formatMenu
        {
            let parent = journey.app.menuBarItems["Format"]
                .menuItems["Paragraph Style"]
            XCTAssertTrue(parent.wait(for: \.isHittable,
                                      toEqual: false, timeout: 5))
        }
        if self == .toolbarOverflow
        {
            XCTAssertTrue(journey.window.popUpButtons["more toolbar items"]
                .isHittable)
        }
        else
        {
            let block = journey.window.popUpButtons["FundamentalBlockStyle"]
            XCTAssertEqual(block.value as? String, title)
        }
    }

    func openCodeLanguage(in journey: WritingUIJourney)
    {
        open("Paragraph Style", in: journey)
        let item = choice("Code Language…", group: "Paragraph Style",
                          in: journey)
        XCTAssertTrue(item.wait(for: \.isHittable, toEqual: true, timeout: 5))
        journey.step("Inspect contextual code choices")
        {
            XCTAssertTrue(item.isEnabled)
        }
        if self == .formatMenu
        {
            journey.app.typeKey(.rightArrow, modifierFlags: [])
            journey.app.typeKey("c", modifierFlags: [])
            journey.app.typeKey(.downArrow, modifierFlags: [])
            journey.app.typeKey(.return, modifierFlags: [])
        }
        else
        {
            item.click()
        }
        journey.step("Inspect code language entry")
        {
            XCTAssertTrue(journey.codeLanguageField.waitForExistence(
                timeout: 5
            ))
        }
    }
}
