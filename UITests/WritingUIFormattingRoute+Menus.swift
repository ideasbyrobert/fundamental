import XCTest

extension WritingUIFormattingRoute
{
    func choice(
        _ title: String, group: String, in app: XCUIApplication
    ) -> XCUIElement
    {
        if self == .formatMenu
        {
            return app.menuBarItems["Format"].menuItems[group].menuItems[title]
        }
        return control(group, in: app).menuItems[title]
    }

    func open(_ group: String, in app: XCUIApplication)
    {
        if self == .toolbar
        {
            control(group, in: app).click()
            return
        }
        let bar = app.menuBars.firstMatch
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

    private func control(_ group: String, in app: XCUIApplication)
        -> XCUIElement
    {
        group == "List" ? app.menuButtons["FundamentalListStyle"]
            : app.popUpButtons["FundamentalBlockStyle"]
    }
}
