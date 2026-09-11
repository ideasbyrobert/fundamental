import XCTest

extension WritingUITests
{
    func testTextStylesFromToolbar() throws
    {
        try exerciseTextStyles(using: .toolbar, width: 820)
    }

    func testTextStylesFromFormatMenu() throws
    {
        try exerciseTextStyles(using: .formatMenu, width: 820)
    }

    func testTextStylesFromOverflow() throws
    {
        try exerciseTextStyles(using: .toolbarOverflow, width: 360)
    }

    private func exerciseTextStyles(
        using route: WritingUIFormattingRoute, width: CGFloat
    ) throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "Text Styles.fun")
        let app = fixture.app
        let text = "Exact e\u{301} 😀 text"
        XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
        journey.editor.click()
        journey.paste(text)
        try journey.saveAs()
        journey.resize(to: width)
        app.typeKey("a", modifierFlags: [.command])
        let choices = [("Bold", "strong"), ("Italic", "emphasis"),
                       ("Underline", "underline"),
                       ("Strikethrough", "strikethrough"),
                       ("Inline Code", "inlineCode"),
                       ("Superscript", "superscript"),
                       ("Subscript", "subscript")]
        for (title, trait) in choices
        {
            try journey.step("Apply and undo " + title)
            {
                route.chooseTextStyle(title, in: journey)
                journey.expectSelection(text)
                _ = try journey.saveInline([[(text, [trait])]])
                app.typeKey("z", modifierFlags: [.command])
                _ = try journey.saveInline([[(text, [])]])
                app.typeKey("z", modifierFlags: [.command, .shift])
                _ = try journey.saveInline([[(text, [trait])]])
                route.chooseTextStyle(title, in: journey)
                _ = try journey.saveInline([[(text, [])]])
                journey.expectSelection(text)
            }
        }
        try journey.step("Resolve mixed text without losing selection")
        {
            try journey.exerciseMixedText(using: route)
        }
        try journey.step("Reopen the saved text styles document")
        {
            try journey.reopen()
            try journey.expectText("First e\u{301} 😀\nSecond plain")
        }
    }
}
