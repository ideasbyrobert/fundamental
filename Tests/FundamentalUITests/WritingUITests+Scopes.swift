import XCTest

extension WritingUITests
{
    func testScopedProsePreservesMeaningThroughDailyEditing() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "Scoped Text.fun")
        let source = WritingUIScopeFixture()
        try source.write(to: journey.document)
        let app = fixture.app
        try journey.step("Open exact links and language scopes")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            try journey.reopen()
            try journey.expectText(source.texts.joined(separator: "\n"))
            let record = try WritingUIRecord(at: journey.document)
            XCTAssertTrue(source.matches(record, texts: source.texts,
                                          forms: [0, 1, 2]))
            source.expectIdentity(record)
        }
        let typed = source.texts[0] + " typed"
        let texts = [typed, "Pasted", source.texts[1], source.texts[2]]
        let forms = [0, 0, 1, 2]
        try journey.step("Type and paste at the end of a linked paragraph")
        {
            journey.editor.click()
            app.typeKey(.upArrow, modifierFlags: [.command])
            app.typeKey(.rightArrow, modifierFlags: [.command])
            app.typeText(" typed")
            journey.paste("\nPasted")
            try journey.expectText(texts.joined(separator: "\n"))
            let record = try journey.save
            {
                source.matches($0, texts: texts, forms: forms)
            }
            source.expectIdentity(record, inserted: true)
            app.typeKey("z", modifierFlags: [.command])
            try journey.expectText(([typed] + source.texts.dropFirst())
                .joined(separator: "\n"))
            app.typeKey("z", modifierFlags: [.command, .shift])
            try journey.expectText(texts.joined(separator: "\n"))
        }
        try journey.step("Format scoped text and preserve it through history")
        {
            app.typeKey("a", modifierFlags: [.command])
            WritingUIFormattingRoute.toolbar.chooseTextStyle(
                "Bold", in: journey
            )
            journey.expectSelection(texts.joined(separator: "\n"))
            _ = try journey.save
            {
                source.matches($0, texts: texts, forms: forms,
                               traits: ["strong"])
            }
            app.typeKey("z", modifierFlags: [.command])
            _ = try journey.save
            {
                source.matches($0, texts: texts, forms: forms)
            }
            app.typeKey("z", modifierFlags: [.command, .shift])
            let record = try journey.save
            {
                source.matches($0, texts: texts, forms: forms,
                               traits: ["strong"])
            }
            source.expectIdentity(record, inserted: true)
        }
        try journey.step("Reopen scopes and visible formatting")
        {
            try journey.reopen()
            try journey.expectText(texts.joined(separator: "\n"))
        }
    }
}
