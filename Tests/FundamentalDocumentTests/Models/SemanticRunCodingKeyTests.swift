import Testing

@testable import FundamentalDocument

@Suite("The semantic run coding keys")
struct SemanticRunCodingKeyTests
{
    @Test("the four coding keys are exact")
    func codingKeysAreExact()
    {
        let keys: [SemanticRunCodingKey] = [
            .text,
            .traits,
            .link,
            .language
        ]
        let rawValues = [
            "text",
            "traits",
            "link",
            "language"
        ]

        #expect(keys.map(\.rawValue) == rawValues)
        #expect(keys.map(\.stringValue) == rawValues)
        #expect(keys.allSatisfy { $0.intValue == nil })
        #expect(SemanticRunCodingKey(rawValue: "unknown") == nil)
    }
}
