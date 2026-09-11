import XCTest

extension WritingUIJourney
{
    func followLink(using route: WritingUIFormattingRoute?, selection: String)
        throws
    {
        if let route
        {
            step("Deliberately open the selected link from its Text group")
            {
                route.chooseTextStyle("Open Link", in: self)
            }
            return
        }
        step("Inspect the owned context menu and cancel without editing")
        {
            editor.coordinate(withNormalizedOffset: .zero)
                .withOffset(CGVector(dx: 60, dy: 45)).rightClick()
            let item = app.menuItems["Open Link"].firstMatch
            XCTAssertTrue(item.wait(for: \.isHittable,
                                   toEqual: true, timeout: 5))
            XCTAssertTrue(item.isEnabled)
            XCTAssertFalse(app.menuItems["Substitutions"].exists)
        }
        try step("Finish context cancellation before copying the selection")
        {
            app.typeKey(.escape, modifierFlags: [])
            let item = app.menuItems["Open Link"].firstMatch
            _ = try XCTUnwrap(item.wait(for: \.isHittable,
                toEqual: false, timeout: 5) ? true : nil)
            expectSelection(selection)
        }
        step("Deliberately follow the link from its context menu")
        {
            editor.coordinate(withNormalizedOffset: .zero)
                .withOffset(CGVector(dx: 60, dy: 45)).rightClick()
            let item = app.menuItems["Open Link"].firstMatch
            XCTAssertTrue(item.wait(for: \.isHittable,
                                   toEqual: true, timeout: 5))
            item.click()
        }
    }
}
