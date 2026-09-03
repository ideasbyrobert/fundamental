import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockSplitTests
{
    @Test("paragraph form remains exact on both sides")
    func paragraphFormRemainsExactOnBothSides() throws
    {
        let prefix = SemanticRun(text: "A\n", traits: [.strong])
        let suffix = SemanticRun(text: "B", traits: [.emphasis])
        let source = try Self.document(blocks: [
            (2, Self.paragraph([prefix, suffix]))
        ])
        let candidate = try Self.apply(at: 2, in: source)
        let result = try #require(candidate)
        let blocks = result.document.content.blocks

        #expect(blocks[0].block == Self.paragraph([prefix]))
        #expect(blocks[1].block == Self.paragraph([suffix]))
        #expect(Self.scalarValues(try Self.text(in: result, at: 0)) ==
            Self.scalarValues("A\n"))
    }

    @Test("title and every section level remain exact")
    func headingFormsRemainExact() throws
    {
        let scopeValues = try SemanticRunAttributesTests.scopes()
        let scopes = try #require(scopeValues.first)
        let prefix = SemanticRun(text: "A", traits: [.strong])
        let suffix = SemanticRun(
            text: "BC",
            attributes: .scoped(traits: [.emphasis], scopes: scopes)
        )
        let runs = [prefix, suffix]
        let expectedPrefix = [prefix]
        let expectedSuffix = [suffix]
        var forms = [(Self.title(runs), Self.title(expectedPrefix),
            Self.title(expectedSuffix))]
        forms += SemanticHeadingLevel.allCases.map
        {
            (
                Self.section(runs, level: $0),
                Self.section(expectedPrefix, level: $0),
                Self.section(expectedSuffix, level: $0)
            )
        }

        for form in forms
        {
            let source = try Self.document(blocks: [(2, form.0)])
            let candidate = try Self.apply(at: 1, in: source)
            let result = try #require(candidate)
            let blocks = result.document.content.blocks

            #expect(blocks[0].block == form.1)
            #expect(blocks[1].block == form.2)
        }
    }

}
