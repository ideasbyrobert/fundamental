import Testing

@testable import FundamentalDocument

@Suite("A semantic text run")
struct SemanticRunTests
{
    @Test("direct initialization creates a direct run")
    func directInitializationCreatesDirectRun()
    {
        let run = SemanticRun(text: "Plain text")

        guard case let .direct(direct) = run
        else
        {
            Issue.record("Expected a direct run")
            return
        }

        #expect(direct.text == "Plain text")
        #expect(direct.traits.isEmpty)
        #expect(run.text == direct.text)
        #expect(run.traits == direct.traits)
    }

    @Test("a scoped run preserves its scope facts")
    func scopedRunPreservesItsScopeFacts() throws
    {
        let link = try #require(
            SemanticLinkDestination("chapter one")
        )
        let run = SemanticRun.scoped(
            SemanticScopedRun(
                text: "Բարև 😀",
                traits: [.strong, .emphasis],
                scopes: .link(link)
            )
        )

        guard case let .scoped(scoped) = run
        else
        {
            Issue.record("Expected a scoped run")
            return
        }

        #expect(scoped.scopes == .link(link))
        #expect(run.text == "Բարև 😀")
        #expect(run.traits == [.strong, .emphasis])
    }

    @Test("reconstruction leaves the original run unchanged")
    func reconstructionLeavesOriginalRunUnchanged()
    {
        let original = SemanticRun(text: "Before")
        let changed = SemanticRun(
            text: "After",
            traits: [.inlineCode]
        )

        #expect(original == SemanticRun(text: "Before"))
        #expect(changed == SemanticRun(
            text: "After",
            traits: [.inlineCode]
        ))
        #expect(original != changed)
    }
}
