import XCTest

extension WritingUITests
{
    func testToolbarOpensLinkWithoutEditing() async throws
    {
        try await exerciseLinkOpening(.toolbar)
    }

    func testFormatMenuOpensLinkWithoutEditing() async throws
    {
        try await exerciseLinkOpening(.formatMenu)
    }

    func testOverflowOpensLinkWithoutEditing() async throws
    {
        try await exerciseLinkOpening(.toolbarOverflow)
    }

    func testContextMenuOpensLinkWithoutEditing() async throws
    {
        try await exerciseLinkOpening(nil)
    }

    private func exerciseLinkOpening(_ route: WritingUIFormattingRoute?)
        async throws
    {
        continueAfterFailure = true
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "Open Link.fun")
        let receiver = try WritingUILinkReceiver()
        addTeardownBlock { await receiver.stop() }
        let address = try await receiver.start()
        let browser = try WritingUILinkBrowser(destination: address,
                                               clipboard: fixture.clipboard)
        addTeardownBlock
        {
            if await receiver.receivedPath != nil
            {
                _ = await MainActor.run { browser.closeIfOwned() }
            }
        }
        let source = WritingUILinkDocument(link: " \(address.absoluteString) ")
        try source.write(to: journey.document)
        try journey.step("Open exact linked text without changing its target")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            try journey.reopen()
            if route == .toolbarOverflow
            {
                journey.resize(to: 360)
            }
            journey.editor.coordinate(withNormalizedOffset: .zero)
                .withOffset(CGVector(dx: 60, dy: 45)).click()
            XCTAssertEqual(journey.app.state, .runningForeground)
            journey.app.typeKey("a", modifierFlags: [.command])
            journey.expectSelection(source.text)
            let record = try journey.saveScopes(source.expected)
            XCTAssertEqual(record.revision, 8)
        }
        let premature = await receiver.receivedPath
        _ = try XCTUnwrap(premature == nil ? true : nil,
            "Selecting linked text must not follow its link")
        try journey.followLink(using: route, selection: source.text)
        let receipt = try await receiver.receipt()
        XCTAssertEqual(receipt, address.path)
        let proof = XCTAttachment(string:
            address.absoluteString + "\n" + receipt)
        proof.name = "Local link request receipt"
        proof.lifetime = .keepAlways
        add(proof)
        try browser.confirmAndClose(test: self)
        fixture.app.activate()
        try journey.step("Return to the exact unchanged selection and document")
        {
            journey.expectSelection(source.text)
            try journey.expectText(source.text)
            let record = try journey.saveScopes(source.expected)
            XCTAssertEqual(record.revision, 8)
            XCTAssertEqual(record.documentID, source.documentID)
            XCTAssertEqual(record.blocks.map(\.blockID), [source.blockID])
            try journey.reopen()
            try journey.expectText(source.text)
        }
    }
}
