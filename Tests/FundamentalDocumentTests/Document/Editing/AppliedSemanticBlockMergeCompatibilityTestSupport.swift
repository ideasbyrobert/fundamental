import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockMergeTests
{
    static func merge(
        _ leading: SemanticBlock,
        _ trailing: SemanticBlock
    ) throws -> AppliedSemanticBlockMerge
    {
        let document = try Self.document(blocks: [
            (2, leading),
            (3, trailing)
        ])
        let candidate = try Self.apply(in: document)
        return try #require(candidate)
    }
}
