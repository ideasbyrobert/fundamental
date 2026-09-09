import Testing

@testable import FundamentalDocument

@Suite("Code conversion uses canonical document ownership")
@MainActor
struct DocumentSessionCodeConversionTests
{
    @Test("joining keeps a backward selection and records one transaction")
    func backwardSelection() throws
    {
        let source = try SemanticWritingTestDocument(
            [.body, .title, .numbered], texts: ["Before", "e\u{301}", "😀B"]
        )
        let range = try source.range((2, 2), (1, 0))
        let session = DocumentSession(
            state: try source.state(range), initiallySaved: true
        )
        let result = session.submit(.convertCode(
            session.observation, SemanticCodeConversion(range: range)
        ))
        guard case let .applied(.editable(after)) = result
        else
        {
            Issue.record("Expected a code conversion")
            return
        }
        CodeConversionTestValue.expectText(
            session.document, ["Before", "e\u{301}\n😀B"]
        )
        let identity = source.document.content.blocks[1].blockID
        #expect(after.selection.range.start.blockID == identity)
        #expect(after.selection.range.end.blockID == identity)
        #expect(after.selection.range.start.utf16Offset.value == 5)
        #expect(after.selection.range.end.utf16Offset.value == 0)
        #expect(session.document.revision.value == 9)
        #expect(after.snapshot.generation.value == 4)
        #expect(session.history.undo.count == 1)
        #expect(session.isDirty)
    }

    @Test("code language changes even when Swift strings compare equal")
    func exactLanguageSpelling() throws
    {
        let runs = [SemanticRun(text: "let x = 1")]
        let source = try SemanticWritingTestDocument(blocks: [
            CodeConversionTestValue.code(runs, language: "é")
        ])
        let session = DocumentSession(
            state: try source.state(), initiallySaved: true
        )
        let tag = try #require(SemanticCodeLanguageIdentifier("e\u{301}"))
        let result = try session.submit(.convertCode(
            session.observation, SemanticCodeConversion(
                range: source.range((0, 0), (0, 0)), codeLanguage: tag
            )
        ))
        guard case .applied = result,
              case let .code(.languageTagged(code)) =
                  session.document.content.blocks[0].block
        else
        {
            Issue.record("Expected exact language spelling to change")
            return
        }
        #expect(code.language.value.utf16.elementsEqual("e\u{301}".utf16))
        #expect(code.runs == runs)
        #expect(session.history.undo.count == 1)
        #expect(session.isDirty)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .undo
        ))
        let restored = try #require(CodeConversionTestValue.language(
            session.document
        ))
        #expect(restored.utf16.elementsEqual("é".utf16))
        #expect(!session.isDirty)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .redo
        ))
        let redone = try #require(CodeConversionTestValue.language(
            session.document
        ))
        #expect(redone.utf16.elementsEqual("e\u{301}".utf16))
        #expect(session.isDirty)
    }
}
