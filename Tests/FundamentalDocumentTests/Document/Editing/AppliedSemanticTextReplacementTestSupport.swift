import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextReplacementTests
{
    static func replacement(
        text: String = "X",
        attributes: SemanticRunAttributes = .direct(traits: []),
        start: Int,
        end: Int,
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2
    ) throws -> SemanticTextReplacement
    {
        let deletion = try AppliedSemanticTextDeletionTests.deletion(
            start: start,
            end: end,
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: blockMarker
        )
        let insertion = try #require(SemanticInsertion(
            text: text,
            attributes: attributes
        ))
        return try #require(SemanticTextReplacement(
            range: deletion.range,
            insertion: insertion
        ))
    }

    static func apply(
        text: String = "X",
        attributes: SemanticRunAttributes = .direct(traits: []),
        start: Int,
        end: Int,
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2,
        blocks: [(UInt8, SemanticBlock)]? = nil
    ) throws -> AppliedSemanticTextEdit?
    {
        let sourceBlocks: [(UInt8, SemanticBlock)]
        if let blocks
        {
            sourceBlocks = blocks
        }
        else
        {
            sourceBlocks = [
                (2, paragraph([SemanticRun(text: "ABCD")]))
            ]
        }
        let document = try Self.document(
            revision: revision,
            blocks: sourceBlocks
        )
        return try apply(
            text: text,
            attributes: attributes,
            start: start,
            end: end,
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: blockMarker,
            in: document
        )
    }

    static func apply(
        text: String = "X",
        attributes: SemanticRunAttributes = .direct(traits: []),
        start: Int,
        end: Int,
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2,
        in document: CanonicalDocument
    ) throws -> AppliedSemanticTextEdit?
    {
        let replacement = try Self.replacement(
            text: text,
            attributes: attributes,
            start: start,
            end: end,
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: blockMarker
        )
        return AppliedSemanticTextEdit(replacement, in: document)
    }
}
