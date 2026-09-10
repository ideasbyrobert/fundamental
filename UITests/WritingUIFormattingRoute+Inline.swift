import XCTest

extension WritingUIFormattingRoute
{
    func chooseTextStyle(_ title: String, in journey: WritingUIJourney)
    {
        open("Text Style", in: journey)
        let item = choice(title, group: "Text Style", in: journey)
        XCTAssertTrue(item.wait(for: \.isHittable, toEqual: true, timeout: 5))
        XCTAssertTrue(item.isEnabled)
        let image = XCTAttachment(screenshot: journey.app.screenshot())
        image.name = "Visible Text style choices: " + title
        image.lifetime = .keepAlways
        XCTContext.runActivity(named: "Inspect Text style choices")
        {
            $0.add(image)
        }
        item.click()
        XCTAssertTrue(item.wait(for: \.isHittable, toEqual: false, timeout: 5))
    }
}
