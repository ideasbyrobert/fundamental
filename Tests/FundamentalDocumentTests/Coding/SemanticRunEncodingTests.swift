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
        }
    }

    @Test("a direct run omits scope keys")
    func directRunOmitsScopeKeys() throws
    {
        let object = try encodedObject(
            for: SemanticRun(text: "Body")
        )

        #expect(Set(object.keys) == Set(["text", "traits"]))
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
