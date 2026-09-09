import XCTest

extension WritingUIJourney
{
    func resize(to width: CGFloat)
    {
        let before = window.frame
        let edge = window.coordinate(withNormalizedOffset:
            CGVector(dx: 1, dy: 0.5)).withOffset(CGVector(dx: -1, dy: 0))
        edge.hover()
        edge.click(forDuration: 0.2, thenDragTo: edge.withOffset(
            CGVector(dx: width - before.width, dy: 0)
        ))
        XCTAssertEqual(window.frame.width, width, accuracy: 1)
        XCTAssertEqual(window.frame.height, before.height, accuracy: 1)
        let controls = [window.popUpButtons["FundamentalBlockStyle"],
                        window.menuButtons["FundamentalListStyle"]]
        if width == 360
        {
            let overflow = window.popUpButtons["more toolbar items"]
            XCTAssertTrue(overflow.isHittable)
            XCTAssertTrue(controls.allSatisfy { !$0.isHittable })
        }
        else
        {
            XCTAssertTrue(controls.allSatisfy { $0.isHittable })
            XCTAssertTrue(controls.allSatisfy
                { window.frame.contains($0.frame) })
        }
    }

    func inspectAndCancel(
        _ title: String, group: String, using route: WritingUIFormattingRoute
    )
    {
        step("Inspect " + group + " with current " + title)
        {
            route.open(group, in: self)
            let item = route.choice(title, group: group, in: self)
            XCTAssertTrue(item.wait(for: \.isHittable,
                                   toEqual: true, timeout: 5))
            XCTAssertTrue(item.isEnabled)
        }
        app.typeKey(.escape, modifierFlags: [])
        if route == .toolbarOverflow
        {
            app.typeKey(.escape, modifierFlags: [])
        }
        XCTAssertTrue(route.choice(title, group: group, in: self)
            .wait(for: \.isHittable, toEqual: false, timeout: 5))
    }

    func saveLastParagraph(numbered: Bool, texts: [String]) throws
        -> WritingUIRecord
    {
        let kind = numbered ? "listItem" : "paragraph"
        let record = try save { $0.blocks.last?.content.kind == kind }
        XCTAssertEqual(record.format, "fundamental-document")
        XCTAssertEqual(record.version, numbered ? 2 : 1)
        XCTAssertEqual(record.blocks.map(\.content.kind),
                       ["section", "paragraph", kind])
        XCTAssertEqual(record.blocks.first?.content.level, 2)
        XCTAssertEqual(record.blocks.last?.content.listKind,
                       numbered ? "numbered" : nil)
        XCTAssertEqual(record.blocks.map
            { $0.content.runs.flatMap { Array($0.text.utf16) } },
            texts.map { Array($0.utf16) })
        XCTAssertTrue(record.blocks.flatMap(\.content.runs)
            .allSatisfy { $0.traits.isEmpty })
        return record
    }
}
