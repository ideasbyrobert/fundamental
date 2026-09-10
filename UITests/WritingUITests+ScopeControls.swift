import XCTest

extension WritingUITests
{
    func testToolbarScopeEditorsPreserveSelectedMeaning() throws
    {
        try exerciseScopeControls(.toolbar)
    }

    func testFormatScopeEditorsPreserveSelectedMeaning() throws
    {
        try exerciseScopeControls(.formatMenu)
    }

    func testOverflowScopeEditorsPreserveSelectedMeaning() throws
    {
        try exerciseScopeControls(.toolbarOverflow)
    }

    private func exerciseScopeControls(_ route: WritingUIFormattingRoute)
        throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "Scope Editors.fun")
        let source = WritingUIScopeControlFixture()
        try source.write(to: journey.document)
        let app = journey.app
        try journey.step("Inspect mixed link values without changing text")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            try journey.reopen()
            if route == .toolbarOverflow
            {
                journey.resize(to: 360)
            }
            journey.editor.click()
            app.typeKey("a", modifierFlags: [.command])
            journey.openScope(using: route)
            XCTAssertEqual(journey.scopeField().value as? String, "")
            XCTAssertEqual(journey.scopeField().placeholderValue,
                           "Multiple values")
            XCTAssertFalse(journey.window.sheets.buttons["Apply"].isEnabled)
            journey.enterScope("Cancelled")
            app.typeKey(.escape, modifierFlags: [])
            XCTAssertTrue(journey.scopeField().waitForNonExistence(timeout: 5))
            journey.expectSelection(source.texts.joined())
            let record = try journey.saveScopes(source.expected())
            XCTAssertEqual(record.revision, 8)
        }
        try journey.editSelectedScopes(source, using: route)
        try journey.step("Reopen the independently saved scope changes")
        {
            try journey.reopen()
            try journey.expectText(source.texts.joined())
            let record = try journey.saveScopes(source.expected(link: nil,
                language: WritingUIScopeControlFixture.changedLanguage))
            XCTAssertEqual(record.documentID, source.documentID)
            XCTAssertEqual(record.blocks.map(\.blockID), [source.blockID])
            XCTAssertEqual(record.blocks.map(\.content.kind), ["paragraph"])
        }
    }
}
