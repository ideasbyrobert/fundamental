import XCTest

extension WritingUIJourney
{
    var document: URL { fixture.directory.appending(path: "Formatting.fun") }

    func saveAs() throws
    {
        app.typeKey("s", modifierFlags: [.command])
        let name = app.textFields["saveAsNameTextField"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        go(to: fixture.directory)
        name.click()
        name.typeKey("a", modifierFlags: [.command])
        name.typeText(document.lastPathComponent)
        app.buttons["OKButton"].click()
        wait("The named document must reach disk")
        {
            FileManager.default.fileExists(atPath: document.path)
        }
    }

    func save(numbered: Bool, texts: [String]) throws -> WritingUIRecord
    {
        app.typeKey("s", modifierFlags: [.command])
        wait("The saved document must contain the current list meaning")
        {
            let record = try? WritingUIRecord(at: document)
            let expected = numbered ? "listItem" : "paragraph"
            return record?.blocks.dropFirst().map(\.content.kind) ==
                [expected, expected]
        }
        let record = try WritingUIRecord(at: document)
        record.expect(numbered: numbered, texts: texts)
        let attachment = XCTAttachment(data: try Data(contentsOf: document),
                                       uniformTypeIdentifier: "public.json")
        attachment.name = "Saved semantic document"
        attachment.lifetime = .keepAlways
        test.add(attachment)
        return record
    }

    func reopen() throws
    {
        app.typeKey("w", modifierFlags: [.command])
        XCTAssertTrue(editor.waitForNonExistence(timeout: 5))
        app.typeKey("o", modifierFlags: [.command])
        go(to: document)
        let open = app.buttons["OKButton"]
        XCTAssertTrue(open.waitForExistence(timeout: 5))
        XCTAssertTrue(open.isEnabled)
        open.click()
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
    }

    private func go(to location: URL)
    {
        app.typeKey("g", modifierFlags: [.command, .shift])
        let path = app.textFields["PathTextField"]
        XCTAssertTrue(path.waitForExistence(timeout: 5))
        path.typeKey("a", modifierFlags: [.command])
        path.typeText(location.path)
        path.typeKey(.return, modifierFlags: [])
        XCTAssertTrue(path.waitForNonExistence(timeout: 5))
    }
}
