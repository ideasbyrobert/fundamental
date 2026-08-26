import Testing

@testable import FundamentalDocument

@Suite("A semantic text run")
struct SemanticRunTests
{
    @Test("text-only initialization uses the exact defaults")
    func textOnlyInitializationUsesDefaults()
    {
        let run = SemanticRun(text: "Plain text")

        #expect(run.text == "Plain text")
        #expect(run.traits.isEmpty)
        #expect(run.link == nil)
        #expect(run.language == nil)
    }

    @Test("every stored field remains mutable")
    func everyStoredFieldRemainsMutable()
    {
        var run = SemanticRun(text: "Before")

        run.text = "After"
        run.traits = [.inlineCode]
        run.link = "chapter two"
        run.language = "en"

        #expect(run.text == "After")
        #expect(run.traits == [.inlineCode])
        #expect(run.link == "chapter two")
        #expect(run.language == "en")
    }

    @Test("full initialization preserves every equatable field")
    func fullInitializationPreservesEveryField()
    {
        let text = "Բարև 😀"
        let traits: Set<SemanticInlineTrait> = [
            .strong,
            .emphasis
        ]
        let link = "chapter one"
        let language = "hy"
        let run = SemanticRun(
            text: text,
            traits: traits,
            link: link,
            language: language
        )

        #expect(run.text == text)
        #expect(run.traits == traits)
        #expect(run.link == link)
        #expect(run.language == language)
        #expect(run == SemanticRun(
            text: text,
            traits: traits,
            link: link,
            language: language
        ))
        #expect(run != SemanticRun(
            text: "Different",
            traits: traits,
            link: link,
            language: language
        ))
        #expect(run != SemanticRun(
            text: text,
            traits: [.strong],
            link: link,
            language: language
        ))
        #expect(run != SemanticRun(
            text: text,
            traits: traits,
            link: nil,
            language: language
        ))
        #expect(run != SemanticRun(
            text: text,
            traits: traits,
            link: link,
            language: nil
        ))
    }
}
