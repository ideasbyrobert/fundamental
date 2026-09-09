import XCTest

extension WritingUITests
{
    func testLightFormattingAtSupportedWidths() async throws
    {
        try await exerciseWidths(appearance: .light)
    }

    func testDarkFormattingAtSupportedWidths() async throws
    {
        try await exerciseWidths(appearance: .dark)
    }

    private func exerciseWidths(appearance: XCUIDevice.Appearance) async throws
    {
        continueAfterFailure = true
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self)
        journey.useAppearance(appearance)
        let texts = ["Formatting at every width", String(repeating:
            "A paragraph with words that wrap naturally. ", count: 24),
            "Caret witness e\u{301} 😀"]
        let text = texts.joined(separator: "\n")
        var prior = try journey.writeHeadingDocument(texts, using: .toolbar)
        journey.app.typeKey(.downArrow, modifierFlags: [.command])
        for width: CGFloat in [360, 540, 820, 1_150]
        {
            let label = "Resize with the caret at the end: \(width)"
            let screenshot = try journey.step(label)
            {
                journey.resize(to: width)
                try journey.expectText(text)
                return try journey.expectAppearance(appearance)
            }
            try await WritingUIVisibleText.expect(
                "Caret witness", in: screenshot, test: self
            )
            let route: WritingUIFormattingRoute = width == 360
                ? .toolbarOverflow : .toolbar
            journey.inspectAndCancel("Body", group: "Paragraph Style",
                                     using: route)
            route.chooseList("Numbered", in: journey)
            let numbered = try journey.saveLastParagraph(
                numbered: true, texts: texts
            )
            journey.expectIdentity(numbered, from: prior)
            journey.inspectAndCancel("Numbered", group: "List", using: route)
            try journey.step("Type at the retained caret and undo: \(width)")
            {
                journey.app.typeText("X")
                try journey.expectText(text + "X")
                journey.app.typeKey("z", modifierFlags: [.command])
                try journey.expectText(text)
            }
            route.chooseList("No List", in: journey)
            prior = try journey.saveLastParagraph(
                numbered: false, texts: texts
            )
            journey.expectIdentity(prior, from: numbered)
        }
        try journey.reopen()
        try journey.expectText(text)
    }
}
