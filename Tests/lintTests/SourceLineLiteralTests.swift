import Testing

@testable import lint

extension SourceLineTests
{
    @Test("comments in ordinary and raw strings are removed")
    func quotedCommentsAreRemoved()
    {
        let ordinary = SourceLine(
            number: 1,
            text: "let url = \"https://example.test\""
        )
        let raw = SourceLine(
            number: 1,
            text: "let marker = #\"/* text */\"#"
        )
        let escaped = SourceLine(
            number: 1,
            text: #"let text = "quoted: \" // text""#
        )
        #expect(!ordinary.carriesComment)
        #expect(!raw.carriesComment)
        #expect(!escaped.carriesComment)
    }

    @Test("multiline string contents remain literal")
    func multilineStringsAreRemoved()
    {
        let ordinary = SourceLine.lines(
            in: "let text = \"\"\"\nhttps://example.test\n\"\"\"\n"
        )
        let raw = SourceLine.lines(
            in: "let text = #\"\"\"\n/* text */\n\"\"\"#\n"
        )
        let nested = SourceLine.lines(
            in: "let text = \"outer \\(\"\"\"\n"
                + "https://example.test\n\"\"\") tail\"\n"
        )
        #expect(!ordinary[1].carriesComment)
        #expect(!raw[1].carriesComment)
        #expect(!nested[1].carriesComment)
    }

    @Test("interpolation contents remain code")
    func interpolatedCommentsAreFound()
    {
        let ordinary = SourceLine(
            number: 1,
            text: "let text = \"\\(value /* no */)\""
        )
        let raw = SourceLine(
            number: 2,
            text: "let text = #\"\\#(value // no)\"#"
        )
        let nestedText = "let text = \"\\(" + "\"https://x\"" + ")\""
        let nested = SourceLine(number: 3, text: nestedText)
        #expect(ordinary.carriesComment)
        #expect(raw.carriesComment)
        #expect(!nested.carriesComment)
    }

    @Test("extended regex contents remain code")
    func regexDoesNotHideTrailingComments()
    {
        let trailing = SourceLine(
            number: 1,
            text: "let regex = #/\"foo/# // no"
        )
        let token = SourceLine(
            number: 2,
            text: "let regex = #/https://example/#"
        )
        let multiline = SourceLine.lines(
            in: "let regex = #/\n\"foo // no\n/#\n"
        )
        #expect(trailing.carriesComment)
        #expect(token.carriesComment)
        #expect(multiline[1].carriesComment)
    }
}
