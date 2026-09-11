import XCTest

extension WritingUITests
{
    func testFormattingAndUndoStayWithTheirDocument() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let first = WritingUIJourney(fixture: fixture, test: self,
                                     documentName: "First.fun")
        let second = WritingUIJourney(fixture: fixture, test: self,
                                      documentName: "Second.fun")
        let app = fixture.app
        let firstTexts = ["First heading", "First item 😀",
                          "First detail e\u{301}"]
        let secondTexts = ["Second heading", "Second item Ω", "Second detail 😀"]
        let originalFirst = try first.step("Write the first named document")
        {
            try first.writeHeadingDocument(firstTexts, using: .toolbar)
        }
        let firstBytes = try Data(contentsOf: first.document)
        app.typeKey("n", modifierFlags: [.command])
        let originalSecond = try second.step("Write the second named document")
        {
            try second.writeHeadingDocument(secondTexts, using: .formatMenu)
        }
        XCTAssertNotEqual(originalFirst.documentID, originalSecond.documentID)
        XCTAssertTrue(app.windows["First.fun"].exists)
        XCTAssertTrue(app.windows["Second.fun"].exists)
        second.selectFollowingParagraphs(secondTexts)
        WritingUIFormattingRoute.toolbar.chooseList("Numbered", in: second)
        _ = try second.save(numbered: true, texts: secondTexts)
        let secondBytes = try Data(contentsOf: second.document)
        XCTAssertEqual(try Data(contentsOf: first.document), firstBytes)
        try first.step("Cycle to the first document and format its selection")
        {
            app.typeKey("`", modifierFlags: [.command])
            first.expectSelection(firstTexts[0])
            first.selectFollowingParagraphs(firstTexts)
            WritingUIFormattingRoute.toolbar.chooseList("Numbered", in: first)
            let record = try first.save(numbered: true, texts: firstTexts)
            first.expectIdentity(record, from: originalFirst)
            XCTAssertEqual(try Data(contentsOf: second.document), secondBytes)
            try second.expectText(secondTexts.joined(separator: "\n"))
        }
        try first.step("Undo only in the first document")
        {
            app.typeKey("z", modifierFlags: [.command])
            _ = try first.save(numbered: false, texts: firstTexts)
            XCTAssertEqual(try Data(contentsOf: second.document), secondBytes)
        }
        let restoredFirst = try Data(contentsOf: first.document)
        try second.step("Cycle back and remove the second document's list")
        {
            app.typeKey("`", modifierFlags: [.command])
            second.expectSelection(secondTexts.dropFirst()
                .joined(separator: "\n"))
            WritingUIFormattingRoute.formatMenu.chooseList("No List",
                                                           in: second)
            let record = try second.save(numbered: false, texts: secondTexts)
            second.expectIdentity(record, from: originalSecond)
            XCTAssertEqual(try Data(contentsOf: first.document), restoredFirst)
        }
        try second.step("Undo only in the second document")
        {
            app.typeKey("z", modifierFlags: [.command])
            _ = try second.save(numbered: true, texts: secondTexts)
            XCTAssertEqual(try Data(contentsOf: first.document), restoredFirst)
            try first.expectText(firstTexts.joined(separator: "\n"))
        }
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }
}
