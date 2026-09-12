import XCTest

extension WritingUIJourney
{
    func chooseFileAction(_ title: String)
    {
        let file = openMenu("File")
        let item = file.menuItems[title]
        XCTAssertTrue(item.wait(for: \.isHittable, toEqual: true, timeout: 5))
        XCTAssertTrue(item.isEnabled)
        item.click()
    }

    func importText(at location: URL)
    {
        chooseFileAction("Import Text…")
        let button = app.buttons["OKButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        go(to: location)
        XCTAssertTrue(button.isEnabled)
        button.click()
    }

    func exportText(named name: String) -> URL
    {
        chooseFileAction("Export Text…")
        let field = app.textFields["saveAsNameTextField"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        go(to: fixture.directory)
        field.click()
        field.typeKey("a", modifierFlags: [.command])
        field.typeText(name)
        app.buttons["OKButton"].click()
        let location = fixture.directory.appending(path: name)
        wait("The text export reaches disk")
        {
            FileManager.default.fileExists(atPath: location.path)
        }
        return location
    }
}
