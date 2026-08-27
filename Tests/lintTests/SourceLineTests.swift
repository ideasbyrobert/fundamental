import Testing

@testable import lint

@Suite("What a line of source says about itself")
struct SourceLineTests
{
    @Test("width counts Swift characters")
    func widthUsesCharacters()
    {
        let tail = String(repeating: "a", count: 78)
        let line = SourceLine(number: 1, text: "— " + tail)
        #expect(line.width == 80)
        let composed = SourceLine(
            number: 2,
            text: String(repeating: "a", count: 79) + "e\u{301}"
        )
        let tabbed = SourceLine(
            number: 3,
            text: "\t" + String(repeating: "a", count: 79)
        )
        let emoji = SourceLine(number: 4, text: composed.text + "👩🏽‍💻")
        #expect(composed.width == 80)
        #expect(tabbed.width == 80)
        #expect(emoji.width == 81)
    }

    @Test("line and block comments are found")
    func commentsAreFound()
    {
        let line = SourceLine(number: 1, text: "let value = 1 // no")
        let block = SourceLine(number: 2, text: "let value = /* no */ 1")
        let doc = SourceLine(number: 3, text: "/// no")
        let blockDoc = SourceLine(number: 4, text: "/** no */")
        let trailing = SourceLine(
            number: 5,
            text: "let url = \"https://example.test\" // no"
        )
        #expect(line.carriesComment)
        #expect(block.carriesComment)
        #expect(doc.carriesComment)
        #expect(blockDoc.carriesComment)
        #expect(trailing.carriesComment)
    }

    @Test("the tools directive is the one comment exemption")
    func toolsVersionIsExempt()
    {
        let line = SourceLine(
            number: 1,
            text: "   // swift-tools-version: 6.4"
        )
        let trailing = SourceLine(
            number: 2,
            text: "let value = 1 // swift-tools-version: 6.4"
        )
        #expect(!line.carriesComment)
        #expect(trailing.carriesComment)
    }

    @Test("only a block keyword ending in a brace is refused")
    func blockOpeningIsSpecific()
    {
        let closure = SourceLine(number: 1, text: "items.map { $0.name }")
        let function = SourceLine(number: 2, text: "func widen() {")
        let handler = SourceLine(number: 3, text: "let handler = {")
        let guardLine = SourceLine(
            number: 4,
            text: "guard let x = y else { return }"
        )
        let modified = SourceLine(
            number: 5,
            text: "package static func perform() {"
        )
        let tabbed = SourceLine(number: 6, text: "func perform() {\t")
        #expect(!closure.opensBraceOnSameLine)
        #expect(function.opensBraceOnSameLine)
        #expect(handler.opensBraceOnSameLine)
        #expect(!guardLine.opensBraceOnSameLine)
        #expect(modified.opensBraceOnSameLine)
        #expect(tabbed.opensBraceOnSameLine)
    }
}
