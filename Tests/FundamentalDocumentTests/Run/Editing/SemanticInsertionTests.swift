import Testing

@testable import FundamentalDocument

@Suite("A semantic insertion")
struct SemanticInsertionTests
{
    @Test("empty spelling is refused for every attribute form")
    func emptySpellingIsRefused() throws
    {
        let direct = SemanticRunAttributes.direct(traits: [])
        let scoped = SemanticRunAttributes.scoped(
            traits: [],
            scopes: try #require(SemanticRunAttributesTests.scopes().first)
        )

        #expect(SemanticInsertion(text: "", attributes: direct) == nil)
        #expect(SemanticInsertion(text: "", attributes: scoped) == nil)
    }

    @Test("occupied spelling is admitted without normalization")
    func occupiedSpellingIsAdmittedWithoutNormalization()
    {
        let attributes = SemanticRunAttributes.direct(traits: [])
        for text in [" ", "\n", "Բարև 😀"]
        {
            let insertion = SemanticInsertion(
                text: text,
                attributes: attributes
            )
            #expect(insertion?.text == text)
        }
    }

    @Test("direct insertion produces the exact run")
    func directInsertionProducesExactRun() throws
    {
        let attributes = SemanticRunAttributes.direct(
            traits: SemanticRunAttributesTests.traits
        )
        let insertion = try #require(SemanticInsertion(
            text: "Direct",
            attributes: attributes
        ))

        #expect(insertion.run == SemanticRunAttributesTests.directRun())
    }

    @Test("scoped insertion produces every exact run form")
    func scopedInsertionProducesEveryExactRunForm() throws
    {
        for scope in try SemanticRunAttributesTests.scopes()
        {
            let attributes = SemanticRunAttributes.scoped(
                traits: SemanticRunAttributesTests.traits,
                scopes: scope
            )
            let insertion = try #require(SemanticInsertion(
                text: "Scoped",
                attributes: attributes
            ))
            #expect(insertion.run ==
                SemanticRunAttributesTests.scopedRun(scope))
        }
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let attributes = SemanticRunAttributes.direct(traits: [.strong])
        let original = try #require(SemanticInsertion(
            text: "Original",
            attributes: attributes
        ))
        let changed = try #require(SemanticInsertion(
            text: "Changed",
            attributes: attributes
        ))

        #expect(original.text == "Original")
        #expect(changed.text == "Changed")
        #expect(original != changed)
    }
}
