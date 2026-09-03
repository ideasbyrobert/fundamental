import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextEditTests
{
    static func document(
        revision: UInt64 = 8,
        blocks: [(UInt8, SemanticBlock)]
    ) throws -> CanonicalDocument
    {
        try ResolvedDocumentPointTests.document(
            revision: revision,
            blocks: blocks
        )
    }

    static func edit(
        text: String = "X",
        attributes: SemanticRunAttributes = .direct(traits: []),
        at offset: Int,
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2
    ) throws -> SemanticTextInsertion
    {
        let point = try ResolvedDocumentPointTests.point(
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: blockMarker,
            offset: offset
        )
        let insertion = try #require(SemanticInsertion(
            text: text,
            attributes: attributes
        ))
        return SemanticTextInsertion(
            point: point,
            insertion: insertion
        )
    }

    static func apply(
        text: String,
        attributes: SemanticRunAttributes = .direct(traits: []),
        at offset: Int,
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2,
        blocks: [(UInt8, SemanticBlock)]? = nil
    ) throws -> AppliedSemanticTextEdit?
    {
        let sourceBlocks = blocks ?? [
            (2, paragraph([SemanticRun(text: "AB")]))
        ]
        let document = try Self.document(
            revision: revision,
            blocks: sourceBlocks
        )
        let edit = try Self.edit(
            text: text,
            attributes: attributes,
            at: offset,
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: blockMarker
        )
        return AppliedSemanticTextEdit(edit, in: document)
    }

    static func apply(
        text: String,
        at offset: Int,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2,
        in document: CanonicalDocument
    ) throws -> AppliedSemanticTextEdit?
    {
        let edit = try Self.edit(
            text: text,
            at: offset,
            revision: revision,
            blockMarker: blockMarker
        )
        return AppliedSemanticTextEdit(edit, in: document)
    }

}
