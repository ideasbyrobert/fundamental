import XCTest

extension WritingUITests
{
    func testCodeEndingCRKeepsKeyboardInputInCode() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "CodeSeams.fun")
        let code = WritingUICodeFixture(tagged: true, source: "A\r")
        try code.write(to: journey.document)
        let app = journey.app
        var block: XCUIElement
        {
            journey.window.popUpButtons["FundamentalBlockStyle"]
        }
        try journey.step("Open code with a final source carriage return")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            try journey.reopen()
            try journey.expectText("Before\nA\r\r\nAfter")
        }
        try journey.step("Arrow into the final code line and type there")
        {
            journey.editor.click()
            app.typeKey(.upArrow, modifierFlags: [.command])
            app.typeKey(.downArrow, modifierFlags: [])
            app.typeKey(.leftArrow, modifierFlags: [.command])
            app.typeKey(.rightArrow, modifierFlags: [])
            app.typeKey(.rightArrow, modifierFlags: [])
            XCTAssertEqual(block.value as? String, "Code")
            app.typeText("Z")
            try journey.expectText("Before\nA\rZ\nAfter")
        }
        try journey.step("Undo and copy only the original code source")
        {
            app.typeKey("z", modifierFlags: [.command])
            try journey.expectText("Before\nA\r\r\nAfter")
            app.typeKey(.leftArrow, modifierFlags: [.shift])
            app.typeKey(.leftArrow, modifierFlags: [.shift])
            journey.expectSelection("A\r")
            app.typeKey("z", modifierFlags: [.command, .shift])
            try journey.expectText("Before\nA\rZ\nAfter")
        }
        try journey.step("Save the source edit and inspect its semantic block")
        {
            let record = try journey.save
            {
                $0.revision > 8 && code.matches($0, code: "A\rZ",
                                                after: "After")
            }
            code.expect(record, code: "A\rZ", after: "After")
        }
        try journey.step("Delete back to the source ending and save it")
        {
            app.typeKey(.delete, modifierFlags: [])
            try journey.expectText("Before\nA\r\r\nAfter")
            let record = try journey.save
            {
                code.matches($0, code: "A\r", after: "After")
            }
            code.expect(record, code: "A\r", after: "After")
        }
        try journey.step("Reopen and reach the final code line again")
        {
            try journey.reopen()
            try journey.expectText("Before\nA\r\r\nAfter")
            journey.editor.click()
            app.typeKey(.upArrow, modifierFlags: [.command])
            app.typeKey(.downArrow, modifierFlags: [])
            app.typeKey(.leftArrow, modifierFlags: [.command])
            app.typeKey(.rightArrow, modifierFlags: [])
            app.typeKey(.rightArrow, modifierFlags: [])
            XCTAssertEqual(block.value as? String, "Code")
        }
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }
}
