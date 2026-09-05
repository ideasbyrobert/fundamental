import Testing

@testable import FundamentalDocument

extension DocumentSessionTransitionTests
{
    static func editable(
        _ result: DocumentSessionTransition
    ) throws -> EditableDocumentSnapshot
    {
        guard case let .applied(.editable(editable)) = result
        else
        {
            throw SessionTestFailure.expectedEditable
        }
        return editable
    }

    static func specialized(
        _ edit: CanonicalDocumentEdit,
        in state: DocumentSessionState
    ) throws -> (CanonicalDocument, ResolvedDocumentPoint)
    {
        let document = state.snapshot.document
        switch edit
        {
        case let .text(text):
            let result = try #require(AppliedSemanticTextEdit(
                text,
                in: document
            ))
            return (result.document, result.caret)
        case let .split(split):
            let result = try #require(AppliedSemanticBlockSplit(
                split,
                in: document
            ))
            return (result.document, result.caret)
        case let .merge(merge):
            let result = try #require(AppliedSemanticBlockMerge(
                merge,
                in: document
            ))
            return (result.document, result.caret)
        }
    }

    static func expectSpelling(
        _ actual: CanonicalDocument,
        _ expected: CanonicalDocument
    ) throws
    {
        #expect(actual.content.blocks.count == expected.content.blocks.count)
        let pairs = zip(actual.content.blocks, expected.content.blocks)
        for (left, right) in pairs
        {
            let leftRuns = try #require(EditableSemanticBlock(left.block)).runs
            let rightBlock = try #require(EditableSemanticBlock(right.block))
            let rightRuns = rightBlock.runs
            #expect(leftRuns.count == rightRuns.count)
            for (leftRun, rightRun) in zip(leftRuns, rightRuns)
            {
                #expect(leftRun.text.utf16.elementsEqual(rightRun.text.utf16))
            }
        }
    }

    static func requireSendable<T: Sendable>(_ type: T.Type)
    {
    }
}
