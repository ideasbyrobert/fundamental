import Testing

@testable import FundamentalDocument

extension DocumentSessionCodeConversionTests
{
    @Test("the current selection maps even when the command targets elsewhere")
    func independentTargetRange() throws
    {
        let source = try SemanticWritingTestDocument(
            [.body, .monostyled, .body], texts: ["Before", "A\r\nB", "After"]
        )
        let current = try source.range((2, 2), (0, 1))
        let session = DocumentSession(state: try source.state(current))
        let conversion = try #require(SemanticCodeConversion(
            range: source.range((1, 0), (1, 0)), proseStyle: .body,
            continuationBlockIDs: CodeConversionTestValue.identities(1)
        ))
        let result = session.submit(.convertCode(
            session.observation, conversion
        ))
        guard case let .applied(.editable(after)) = result
        else
        {
            Issue.record("Expected selected code to split")
            return
        }
        #expect(after.selection.range.start.blockID == current.start.blockID)
        #expect(after.selection.range.end.blockID == current.end.blockID)
        #expect(after.selection.range.start.utf16Offset ==
            current.start.utf16Offset)
        #expect(after.selection.range.end.utf16Offset ==
            current.end.utf16Offset)
        CodeConversionTestValue.expectText(
            session.document, ["Before", "A", "B", "After"]
        )
    }

    @Test("a caret in a removed identity maps inside the merged code")
    func currentCaretInsideTarget() throws
    {
        let source = try SemanticWritingTestDocument(
            [.body, .body, .body], texts: ["A", "e\u{301}", "After"]
        )
        let session = DocumentSession(state: try source.state(
            source.range((1, 2), (1, 2))
        ))
        let result = try session.submit(.convertCode(
            session.observation,
            SemanticCodeConversion(range: source.range((0, 0), (2, 0)))
        ))
        guard case let .applied(.editable(after)) = result
        else
        {
            Issue.record("Expected a mapped caret")
            return
        }
        #expect(after.selection.isCollapsed)
        #expect(after.selection.range.start.blockID ==
            source.document.content.blocks[0].blockID)
        #expect(after.selection.range.start.utf16Offset.value == 4)
    }
}
