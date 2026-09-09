import XCTest

extension WritingUIFormattingRoute
{
    func choice(
        _ title: String, group: String, in journey: WritingUIJourney
    ) -> XCUIElement
    {
        if self == .toolbarOverflow
        {
            return journey.window.popUpButtons["more toolbar items"]
                .menuItems[group].menuItems[title]
        }
        if self == .formatMenu
        {
            return journey.app.menuBarItems["Format"]
                .menuItems[group].menuItems[title]
        }
        return control(group, in: journey.window).menuItems[title]
    }

    func open(_ group: String, in journey: WritingUIJourney)
    {
        if self == .toolbarOverflow
        {
            let overflow = journey.window.popUpButtons["more toolbar items"]
            XCTAssertTrue(overflow.isHittable)
            overflow.click()
            let submenu = overflow.menuItems[group]
            XCTAssertTrue(submenu.wait(for: \.isHittable,
                                       toEqual: true, timeout: 5))
            submenu.hover()
            journey.app.typeKey(.rightArrow, modifierFlags: [])
            return
        }
        if self == .toolbar
        {
            control(group, in: journey.window).click()
            return
        }
        let bar = journey.app.menuBars.firstMatch
        bar.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.05))
            .hover()
        let format = bar.menuBarItems["Format"]
        XCTAssertTrue(format.wait(for: \.isHittable, toEqual: true, timeout: 5))
        format.click()
        let submenu = format.menuItems[group]
        XCTAssertTrue(submenu.wait(for: \.isHittable,
                                   toEqual: true, timeout: 5))
        submenu.hover()
    }

    private func control(_ group: String, in window: XCUIElement)
        -> XCUIElement
    {
        group == "List" ? window.menuButtons["FundamentalListStyle"]
            : window.popUpButtons["FundamentalBlockStyle"]
    }
}
