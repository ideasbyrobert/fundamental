import Testing

@testable import FundamentalDocument

extension SemanticRunPartitionTests
{
    static func offset(_ value: Int) throws -> DocumentUTF16Offset
    {
        try #require(DocumentUTF16Offset(value))
    }

    static func partition(
        _ runs: [SemanticRun],
        _ lowerBound: Int,
        _ upperBound: Int
    ) throws -> SemanticRunPartition
    {
        try #require(SemanticRunPartition(
            runs: runs,
            lowerBound: offset(lowerBound),
            upperBound: offset(upperBound)
        ))
    }

    static func direct(
        _ text: String,
        traits: Set<SemanticInlineTrait> = []
    ) -> SemanticRun
    {
        SemanticRun(text: text, traits: traits)
    }

    static func scoped(
        _ text: String,
        _ scopes: SemanticRunScopes,
        traits: Set<SemanticInlineTrait> = []
    ) -> SemanticRun
    {
        .scoped(SemanticScopedRun(
            text: text,
            traits: traits,
            scopes: scopes
        ))
    }

    static func scalarValues(_ runs: [SemanticRun]) -> [UInt32]
    {
        runs.flatMap
        {
            $0.text.unicodeScalars.map(\.value)
        }
    }
}
