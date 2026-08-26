import Foundation
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

    @Test("traits encode in stable raw-value order")
    func traitsEncodeInStableRawValueOrder() throws
    {
        let expectedTraits: [SemanticInlineTrait] = [
            .emphasis,
            .inlineCode,
            .strikethrough,
            .strong,
            .subscriptText,
            .superscript,
            .underline
        ]
        let sourceOrders = [
            expectedTraits,
            Array(expectedTraits.reversed())
        ]

        for sourceOrder in sourceOrders
        {
            let run = SemanticRun(
                text: "Body",
                traits: Set(sourceOrder)
            )
            let object = try encodedObject(for: run)
            let rawValues = try #require(
                object["traits"] as? [String]
            )

            #expect(rawValues == expectedTraits.map(\.rawValue))
            #expect(Set(object.keys) == Set(["text", "traits"]))
        }
    }

    @Test("a full Unicode run round trips semantically")
    func fullUnicodeRunRoundTrips() throws
    {
        let run = SemanticRun(
            text: "Բարև 😀",
            traits: [.strong, .emphasis, .inlineCode],
            link: "chapter one",
            language: "hy"
        )
        let data = try JSONEncoder().encode(run)
        let decoded = try JSONDecoder().decode(
            SemanticRun.self,
            from: data
        )
        let object = try encodedObject(for: run)

        #expect(decoded == run)
        #expect(object["text"] as? String == run.text)
        #expect(object["link"] as? String == run.link)
        #expect(object["language"] as? String == run.language)
        #expect(Set(object.keys) == Set([
            "language",
            "link",
            "text",
            "traits"
        ]))
    }

    @Test("compatible payloads decode and invalid payloads are refused")
    func compatiblePayloadsDecodeAndInvalidPayloadsAreRefused() throws
    {
        let unordered = Data(
            #"""
            {"text":"Body","traits":["underline","strong","emphasis","strong"]}
            """#.utf8
        )
        let decoded = try JSONDecoder().decode(
            SemanticRun.self,
            from: unordered
        )

        #expect(decoded.text == "Body")
        #expect(decoded.traits == [.underline, .strong, .emphasis])
        #expect(decoded.link == nil)
        #expect(decoded.language == nil)

        let nullOptionals = Data(
            #"{"text":"Body","traits":[],"link":null,"language":null}"#.utf8
        )
        let decodedNulls = try JSONDecoder().decode(
            SemanticRun.self,
            from: nullOptionals
        )

        #expect(decodedNulls.link == nil)
        #expect(decodedNulls.language == nil)

        let invalidPayloads = [
            Data(#"{"traits":[]}"#.utf8),
            Data(#"{"text":"Body"}"#.utf8),
            Data(#"{"text":"Body","traits":["bold"]}"#.utf8)
        ]
        for data in invalidPayloads
        {
            #expect(throws: DecodingError.self)
            {
                try JSONDecoder().decode(
                    SemanticRun.self,
                    from: data
                )
            }
        }
    }

    private func encodedObject(
        for run: SemanticRun
    ) throws -> [String: Any]
    {
        let data = try JSONEncoder().encode(run)
        return try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
    }
}
