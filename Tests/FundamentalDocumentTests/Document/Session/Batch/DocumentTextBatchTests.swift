import Testing

@testable import FundamentalDocument

@MainActor
@Suite("Atomic text replacement batches")
struct DocumentTextBatchTests
{
    static func batch(
        _ values: [(Int, Range<Int>, String)], in fixture: SessionTestDocument
    ) throws -> SemanticTextBatchReplacement
    {
        let substitutions = try values.map
        {
            block, offsets, text in
            let start = try fixture.point(offsets.lowerBound, block: block)
            let end = try fixture.point(offsets.upperBound, block: block)
            let range = try #require(DocumentRange(start: start, end: end))
            return try #require(SemanticTextSubstitution(
                range: range, text: text, attributes: .direct(traits: [])
            ))
        }
        return try #require(SemanticTextBatchReplacement(substitutions))
    }

    static func spelling(_ session: DocumentSession) throws -> [[UInt16]]
    {
        try session.document.content.blocks.map
        {
            let block = try #require(EditableSemanticBlock($0.block))
            return block.runs.flatMap { Array($0.text.utf16) }
        }
    }

    static func expectPersistence(
        _ session: DocumentSession, _ previous: DocumentSessionPersistence
    )
    {
        #expect(session.persistence.sessionID == previous.sessionID)
        #expect(session.persistence.latestRequestID == previous.latestRequestID)
        #expect(session.persistence.contentRevision == previous.contentRevision)
        #expect(session.persistence.savedContentRevision ==
            previous.savedContentRevision)
    }

    static func move(
        _ session: DocumentSession, _ direction: DocumentHistoryDirection
    ) throws
    {
        guard case .applied = session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: direction
        ))
        else
        {
            Issue.record("Expected the complete batch to traverse history")
            return
        }
    }
}
