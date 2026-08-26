import Foundation
import Testing

@testable import FundamentalDocument

@Suite("The semantic inline traits")
struct SemanticInlineTraitTests
{
    private let inlineTraits: [SemanticInlineTrait] = [
        .strong,
        .emphasis,
        .underline,
        .strikethrough,
        .inlineCode,
        .superscript,
        .subscriptText
    ]

    @Test("the compatibility vocabulary and raw values are exact")
    func vocabularyIsExact()
    {
        #expect(inlineTraits.count == 7)
        #expect(Set(inlineTraits).count == inlineTraits.count)
        for inlineTrait in inlineTraits
        {
            let rawValue = expectedRawValue(for: inlineTrait)
            #expect(inlineTrait.rawValue == rawValue)
            #expect(SemanticInlineTrait(rawValue: rawValue) == inlineTrait)
        }
    }

    @Test("every inline trait has a deterministic Codable round trip")
    func inlineTraitsRoundTrip() throws
    {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for inlineTrait in inlineTraits
        {
            let rawValue = expectedRawValue(for: inlineTrait)
            let data = try encoder.encode(inlineTrait)
            let decoded = try decoder.decode(
                SemanticInlineTrait.self,
                from: data
            )
            #expect(decoded == inlineTrait)
            #expect(data == Data("\"\(rawValue)\"".utf8))
        }
    }

    @Test("nonarchive spellings are refused")
    func nonarchiveSpellingsAreRefused()
    {
        for rawValue in ["bold", "italic", "subscriptText"]
        {
            #expect(SemanticInlineTrait(rawValue: rawValue) == nil)
            let data = Data("\"\(rawValue)\"".utf8)
            #expect(throws: DecodingError.self)
            {
                try JSONDecoder().decode(
                    SemanticInlineTrait.self,
                    from: data
                )
            }
        }
    }

    private func expectedRawValue(
        for inlineTrait: SemanticInlineTrait
    ) -> String
    {
        switch inlineTrait
        {
        case .strong:
            "strong"
        case .emphasis:
            "emphasis"
        case .underline:
            "underline"
        case .strikethrough:
            "strikethrough"
        case .inlineCode:
            "inlineCode"
        case .superscript:
            "superscript"
        case .subscriptText:
            "subscript"
        }
    }
}
