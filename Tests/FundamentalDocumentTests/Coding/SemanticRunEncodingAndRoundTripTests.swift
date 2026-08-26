import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticRunTests
{
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
