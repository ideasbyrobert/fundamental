import Foundation
import Testing

@testable import FundamentalDocument

@Suite("The semantic role hints")
struct SemanticRoleHintTests
{
    private let roleHints: [SemanticRoleHint] = [
        .title,
        .heading1,
        .heading2,
        .heading3,
        .body,
        .quote,
        .code,
        .bullet,
        .numberedItem,
        .sceneBreak,
        .caption
    ]

    @Test("the compatibility vocabulary and raw values are exact")
    func vocabularyIsExact()
    {
        #expect(roleHints.count == 11)
        for roleHint in roleHints
        {
            let rawValue = expectedRawValue(for: roleHint)
            #expect(roleHint.rawValue == rawValue)
            #expect(SemanticRoleHint(rawValue: rawValue) == roleHint)
        }
    }

    @Test("every role hint has a deterministic Codable round trip")
    func roleHintsRoundTrip() throws
    {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for roleHint in roleHints
        {
            let rawValue = expectedRawValue(for: roleHint)
            let data = try encoder.encode(roleHint)
            let decoded = try decoder.decode(
                SemanticRoleHint.self,
                from: data
            )
            #expect(decoded == roleHint)
            #expect(data == Data("\"\(rawValue)\"".utf8))
        }
    }

    @Test("subheading is not a semantic role hint")
    func subheadingIsRefused()
    {
        #expect(SemanticRoleHint(rawValue: "subheading") == nil)
        let data = Data(#""subheading""#.utf8)
        #expect(throws: DecodingError.self)
        {
            try JSONDecoder().decode(
                SemanticRoleHint.self,
                from: data
            )
        }
    }

    private func expectedRawValue(
        for roleHint: SemanticRoleHint
    ) -> String
    {
        switch roleHint
        {
        case .title:
            "title"
        case .heading1:
            "heading1"
        case .heading2:
            "heading2"
        case .heading3:
            "heading3"
        case .body:
            "body"
        case .quote:
            "quote"
        case .code:
            "code"
        case .bullet:
            "bullet"
        case .numberedItem:
            "numberedItem"
        case .sceneBreak:
            "sceneBreak"
        case .caption:
            "caption"
        }
    }
}
