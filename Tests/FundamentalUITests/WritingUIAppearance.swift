import XCTest

@MainActor
enum WritingUIAppearance
{
    static func use(_ appearance: XCUIDevice.Appearance, test: XCTestCase)
    {
        let prior = XCUIDevice.shared.appearance
        test.addTeardownBlock
        {
            @MainActor in
            if XCUIDevice.shared.appearance != prior
            {
                XCUIDevice.shared.appearance = prior
            }
            XCTAssertEqual(XCUIDevice.shared.appearance, prior)
            print("Restored device appearance: \(prior.rawValue)")
        }
        print("Initial device appearance: \(prior.rawValue)")
        if prior != appearance
        {
            XCUIDevice.shared.appearance = appearance
        }
        XCTAssertEqual(XCUIDevice.shared.appearance, appearance)
    }
}
