import Testing

@testable import FundamentalDocument

extension SemanticTextEditTests
{
    static func point(
        blockMarker: UInt8 = 3,
        offset: Int
    ) throws -> DocumentPoint
    {
        try DocumentRangeTests.point(
            blockMarker: blockMarker,
            offset: offset
        )
    }

    static func range(
        from start: Int,
        to end: Int
    ) throws -> DocumentRange
    {
        try range(from: (3, start), to: (3, end))
    }

    static func range(
        from start: (UInt8, Int),
        to end: (UInt8, Int)
    ) throws -> DocumentRange
    {
        try #require(DocumentRange(
            start: point(blockMarker: start.0, offset: start.1),
            end: point(blockMarker: end.0, offset: end.1)
        ))
    }

    static func insertion(_ text: String) throws -> SemanticInsertion
    {
        try #require(SemanticInsertion(
            text: text,
            attributes: .direct(traits: [.strong])
        ))
    }

    static func scopedInsertion(
        _ text: String
    ) throws -> SemanticInsertion
    {
        let scopes = try #require(
            SemanticRunAttributesTests.scopes().last
        )
        return try #require(SemanticInsertion(
            text: text,
            attributes: .scoped(
                traits: [.emphasis],
                scopes: scopes
            )
        ))
    }

    static func values() throws -> (
        insertion: SemanticTextInsertion,
        deletion: SemanticTextDeletion,
        replacement: SemanticTextReplacement
    )
    {
        let insertion = try Self.insertion("Text")
        return (
            SemanticTextInsertion(
                point: try point(offset: 2),
                insertion: insertion
            ),
            try #require(SemanticTextDeletion(
                range: range(from: 2, to: 5)
            )),
            try #require(SemanticTextReplacement(
                range: range(from: 2, to: 5),
                insertion: insertion
            ))
        )
    }

    static func form(_ edit: SemanticTextEdit) -> Int
    {
        switch edit
        {
        case .insertion:
            0
        case .deletion:
            1
        case .replacement:
            2
        }
    }

    static func acceptsSendable<T: Sendable>(_ value: T)
    {
    }
}
