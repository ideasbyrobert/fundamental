import XCTest

extension WritingUIJourney
{
    func saveHeadings(level: Int, texts: [String]) throws -> WritingUIRecord
    {
        let kind = level == 0 ? "paragraph" : "section"
        let kinds = ["title", kind, kind]
        let value: Int? = level == 0 ? nil : level
        let levels: [Int?] = [nil, value, value]
        let record = try save
        {
            $0.blocks.map(\.content.kind) == kinds &&
                $0.blocks.map(\.content.level) == levels
        }
        XCTAssertEqual(record.format, "fundamental-document")
        XCTAssertEqual(record.version, 1)
        XCTAssertEqual(record.blocks.map
            { $0.content.runs.flatMap { Array($0.text.utf16) } },
            texts.map { Array($0.utf16) })
        XCTAssertTrue(record.blocks.allSatisfy
            { $0.content.listKind == nil && $0.content.language == nil })
        XCTAssertTrue(record.blocks.flatMap(\.content.runs).allSatisfy
            { $0.traits.isEmpty && $0.link == nil && $0.language == nil })
        return record
    }

    func inspectMixedHeadings(using route: WritingUIFormattingRoute)
    {
        let block = window.popUpButtons["FundamentalBlockStyle"]
        if route != .toolbarOverflow
        {
            XCTAssertEqual(block.value as? String, "Mixed")
        }
        step("Open mixed paragraph choices")
        {
            route.open("Paragraph Style", in: self)
        }
        let titles = ["Body", "Title"] +
            (1 ... 6).map { "Heading \($0)" } + ["Code"]
        for (index, title) in titles.enumerated()
        {
            step("Reach paragraph choice: " + title)
            {
                if route == .toolbar && index == 0
                {
                    app.typeKey("b", modifierFlags: [])
                }
                else if route == .toolbar
                {
                    app.typeKey(.downArrow, modifierFlags: [])
                }
                let item = route.choice(title, group: "Paragraph Style",
                                        in: self)
                XCTAssertTrue(item.wait(for: \.isHittable,
                                        toEqual: true, timeout: 5))
                XCTAssertTrue(item.isEnabled)
            }
        }
        if route == .toolbar
        {
            XCTAssertFalse(block.menuItems["Mixed"].isEnabled)
        }
        app.typeKey(.escape, modifierFlags: [])
        if route == .toolbarOverflow
        {
            app.typeKey(.escape, modifierFlags: [])
        }
        if route == .formatMenu && app.menuBarItems["Format"]
            .menuItems["Paragraph Style"].isHittable
        {
            app.typeKey(.escape, modifierFlags: [])
        }
        XCTAssertTrue(route.choice("Heading 6", group: "Paragraph Style",
                                  in: self).wait(for: \.isHittable,
                                                toEqual: false, timeout: 5))
    }
}
