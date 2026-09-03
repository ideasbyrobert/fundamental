import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextReplacementTests
{
    @Test("every inserted attribute form remains exact")
    func everyInsertedAttributeFormRemainsExact() throws
    {
        let scopes = try SemanticRunAttributesTests.scopes()
        let attributes: [SemanticRunAttributes] = [
            .direct(traits: [.strong])
        ] + scopes.map { .scoped(traits: [.emphasis], scopes: $0) }
        let sourceAttributes = SemanticRunAttributes.direct(traits: [])

        for attribute in attributes
        {
            let blocks: [(UInt8, SemanticBlock)] = [
                (2, Self.paragraph([
                    SemanticRun(text: "ABC", attributes: sourceAttributes)
                ]))
            ]
            let candidate = try Self.apply(
                attributes: attribute,
                start: 1,
                end: 2,
                blocks: blocks
            )
            let result = try #require(candidate)

            #expect(try Self.runs(in: result) == [
                SemanticRun(text: "A", attributes: sourceAttributes),
                SemanticRun(text: "X", attributes: attribute),
                SemanticRun(text: "C", attributes: sourceAttributes)
            ])
        }

        let equal = SemanticRunAttributes.direct(traits: [.strong])
        let equalBlocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([
                SemanticRun(text: "ABC", attributes: equal)
            ]))
        ]
        let equalCandidate = try Self.apply(
            attributes: equal,
            start: 1,
            end: 2,
            blocks: equalBlocks
        )
        let equalResult = try #require(equalCandidate)
        #expect(try Self.runs(in: equalResult) == [
            SemanticRun(text: "A", attributes: equal),
            SemanticRun(text: "X", attributes: equal),
            SemanticRun(text: "C", attributes: equal)
        ])
    }

    @Test("cross-run replacement retains exact surviving attributes")
    func crossRunReplacementRetainsSurvivingAttributes() throws
    {
        let prefix = SemanticRunAttributes.direct(traits: [.strong])
        let scope = try #require(SemanticRunAttributesTests.scopes().first)
        let suffix = SemanticRunAttributes.scoped(
            traits: [.emphasis],
            scopes: scope
        )
        let insertion = SemanticRunAttributes.direct(traits: [.inlineCode])
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([
                SemanticRun(text: "AB", attributes: prefix),
                SemanticRun(text: "CD"),
                SemanticRun(text: "EF", attributes: suffix)
            ]))
        ]
        let candidate = try Self.apply(
            attributes: insertion,
            start: 1,
            end: 5,
            blocks: blocks
        )
        let result = try #require(candidate)

        #expect(try Self.runs(in: result) == [
            SemanticRun(text: "A", attributes: prefix),
            SemanticRun(text: "X", attributes: insertion),
            SemanticRun(text: "F", attributes: suffix)
        ])
    }

}
