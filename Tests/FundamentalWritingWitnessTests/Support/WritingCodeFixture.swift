import Testing

@testable import FundamentalDocument

enum WritingCodeFixture
{
    static let language = " SwIfT "
    static let text = "let letter = \"e\u{301} 😀\"\r\n\treturn letter\n\n"

    static func block(_ text: String, tagged: Bool) throws -> SemanticBlock
    {
        let runs = text.isEmpty ? [] : [SemanticRun(text: text)]
        if tagged
        {
            let identifier = try #require(SemanticCodeLanguageIdentifier(
                language
            ))
            return .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: runs, language: identifier
            )))
        }
        return .code(.plain(PlainSemanticCodeBlock(runs: runs)))
    }

    static func document(_ text: String, tagged: Bool) throws
        -> WritingTestDocument
    {
        try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "Before")])),
            block(text, tagged: tagged),
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "After")]))
        ])
    }

    static func expect(_ block: SemanticBlock, text: String, tagged: Bool)
        throws
    {
        let runs: [SemanticRun]
        switch block
        {
        case let .code(.plain(code)):
            #expect(!tagged)
            runs = code.runs
        case let .code(.languageTagged(code)):
            #expect(tagged)
            #expect(code.language.value.utf16.elementsEqual(language.utf16))
            runs = code.runs
        default:
            Issue.record("Expected the original semantic code form")
            throw WritingTestFailure.expectedEditable
        }
        #expect(runs.flatMap { Array($0.text.utf16) } == Array(text.utf16))
        #expect(runs.allSatisfy { $0.attributes == .direct(traits: []) })
    }
}
