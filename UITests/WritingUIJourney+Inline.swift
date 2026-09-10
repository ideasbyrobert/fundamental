import XCTest

extension WritingUIJourney
{
    func saveInline(_ paragraphs: [[(String, [String])]]) throws
        -> WritingUIRecord
    {
        let state = WritingUIInlineState(paragraphs: paragraphs)
        let record = try save { state.matches($0) }
        XCTAssertTrue(state.matches(record))
        return record
    }

    func exerciseMixedText(using route: WritingUIFormattingRoute) throws
    {
        let texts = ["First e\u{301} 😀", "Second plain"]
        app.typeKey("a", modifierFlags: [.command])
        paste(texts.joined(separator: "\n"))
        app.typeKey(.upArrow, modifierFlags: [.command])
        app.typeKey(.rightArrow, modifierFlags: [.command, .shift])
        expectSelection(texts[0])
        route.chooseTextStyle("Bold", in: self)
        let mixed = [[(texts[0], ["strong"])], [(texts[1], [String]())]]
        let original = try saveInline(mixed)
        app.typeKey("a", modifierFlags: [.command])
        inspectAndCancel("Bold", group: "Text Style", using: route)
        expectSelection(texts.joined(separator: "\n"))
        route.chooseTextStyle("Bold", in: self)
        let uniform = texts.map { [($0, ["strong"])] }
        let changed = try saveInline(uniform)
        expectIdentity(changed, from: original)
        app.typeKey("z", modifierFlags: [.command])
        _ = try saveInline(mixed)
        app.typeKey("z", modifierFlags: [.command, .shift])
        _ = try saveInline(uniform)
        expectSelection(texts.joined(separator: "\n"))
        route.chooseTextStyle("Bold", in: self)
        _ = try saveInline(texts.map { [($0, [])] })
    }
}
