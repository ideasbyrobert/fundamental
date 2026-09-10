import Testing

@testable import FundamentalDocument

extension DocumentSessionCodeConversionTests
{
    @Test("code converts to every exact heading level without losing meaning",
          arguments: SemanticHeadingLevel.allCases)
    func exactHeadingConversion(_ level: SemanticHeadingLevel) throws
    {
        let runs = try HeadingTestValue.runs()
        let codeRuns = runs + [SemanticRun(text: "\r\n")] + runs
        let text = codeRuns.map(\.text).joined()
        let source = try SemanticWritingTestDocument(blocks: [
            CodeConversionTestValue.code(codeRuns, language: " SwIfT ")
        ])
        let range = try source.range((0, text.utf16.count), (0, 0))
        let session = DocumentSession(
            state: try source.state(range), initiallySaved: true
        )
        let added = CodeConversionTestValue.identities(1)
        let conversion = try #require(SemanticCodeConversion(
            range: range, proseStyle: HeadingTestValue.style(level),
            continuationBlockIDs: added
        ))
        let result = session.submit(.convertCode(
            session.observation, conversion
        ))
        guard case let .applied(.editable(after)) = result
        else
        {
            Issue.record("Expected code lines to become exact headings")
            return
        }
        HeadingTestValue.expect(session.document, level: level, runs: runs)
        #expect(session.document.content.blocks.map(\.blockID) ==
            [source.document.content.blocks[0].blockID] + added)
        #expect(after.selection.range.start.blockID == added[0])
        #expect(after.selection.range.start.utf16Offset.value ==
            runs.map(\.text).joined().utf16.count)
        #expect(after.selection.range.end.blockID == range.end.blockID)
        #expect(after.selection.range.end.utf16Offset.value == 0)
        let converted = session.document.content
        #expect(session.history.undo.count == 1)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .undo
        ))
        #expect(session.document.content == source.document.content)
        #expect(CodeConversionTestValue.language(session.document) == " SwIfT ")
        CodeConversionTestValue.expectText(session.document, [text])
        #expect(!session.isDirty)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .redo
        ))
        #expect(session.document.content == converted)
        HeadingTestValue.expect(session.document, level: level, runs: runs)
    }
}
