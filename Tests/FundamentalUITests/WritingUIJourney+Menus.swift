import XCTest

extension WritingUIJourney
{
    func openMenu(_ title: String) -> XCUIElement
    {
        let bar = app.menuBars.firstMatch
        bar.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.05))
            .hover()
        let menu = bar.menuBarItems[title]
        XCTAssertTrue(menu.wait(for: \.isHittable, toEqual: true, timeout: 5))
        menu.click()
        return menu
    }
}
