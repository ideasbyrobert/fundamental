import Foundation
import Testing

@testable import FundamentalDocument

extension DocumentSessionTypingTests
{
    @Test("block style and code conversion retain intent at the caret")
    func formatting() throws
    {
        let source = try SemanticWritingTestDocument([.body])
        let session = DocumentSession(state: try source.state())
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: .strong, enabled: true)
        ))
        let intent = try Self.editable(session).typingIntent
        session.submit(.style(session.observation, SemanticBlockStyleChange(
            range: try Self.editable(session).selection.range, style: .heading
        )))
        #expect(try Self.editable(session).typingIntent == intent)
        session.submit(.convertCode(session.observation, SemanticCodeConversion(
            range: try Self.editable(session).selection.range,
            codeLanguage: SemanticCodeLanguageIdentifier(" SwIfT ")
        )))
        #expect(try Self.editable(session).typingIntent == intent)
        try Self.insert("e\u{301}\r\n😀", into: session)
        #expect(try Self.editable(session).typingIntent == intent)
        CodeConversionTestValue.expectText(session.document,
                                           ["e\u{301}\r\n😀ABCD"])
        #expect(CodeConversionTestValue.language(session.document) == " SwIfT ")
    }

    @Test("a caret split retains intent and a strict merge clears it")
    func splitAndMerge() throws
    {
        let source = try SemanticWritingTestDocument([.body])
        let session = DocumentSession(state: try source.state(
            source.range((0, 4), (0, 4))
        ))
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: .strong, enabled: true)
        ))
        let split = try #require(SemanticBlockSplit(
            point: source.point(0, 4),
            continuationBlockID: FundamentalBlockID(UUID())
        ))
        session.submit(.edit(session.observation, .split(split)))
        #expect(try Self.editable(session).typingIntent?.attributes ==
            .direct(traits: [.strong]))
        let document = session.document
        let merge = try #require(SemanticBlockMerge(
            documentID: document.documentID, revision: document.revision,
            leadingBlockID: document.content.blocks[0].blockID,
            trailingBlockID: document.content.blocks[1].blockID
        ))
        session.submit(.edit(session.observation, .merge(merge)))
        #expect(try Self.editable(session).typingIntent == nil)
        CodeConversionTestValue.expectText(session.document, ["ABCD"])
    }
}
