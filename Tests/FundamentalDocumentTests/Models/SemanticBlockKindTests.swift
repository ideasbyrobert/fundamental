import Foundation
import Testing

@testable import FundamentalDocument

@Suite("The semantic block kinds")
struct SemanticBlockKindTests
{
    private let kinds: [SemanticBlockKind] = [
        .paragraph,
        .heading,
        .quote,
        .code,
        .listItem,
        .sceneBreak,
        .table,
        .image,
        .rawHTML
    ]

    @Test("the compatibility vocabulary and raw values are exact")
    func vocabularyIsExact()
    {
        #expect(kinds.count == 9)
        for kind in kinds
        {
            let rawValue = expectedRawValue(for: kind)
            #expect(kind.rawValue == rawValue)
            #expect(SemanticBlockKind(rawValue: rawValue) == kind)
        }
    }

    @Test("every compatibility kind has a deterministic Codable round trip")
    func compatibilityKindsRoundTrip() throws
    {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for kind in kinds
        {
            let rawValue = expectedRawValue(for: kind)
            let data = try encoder.encode(kind)
            let decoded = try decoder.decode(
                SemanticBlockKind.self,
                from: data
            )
            #expect(decoded == kind)
            #expect(data == Data("\"\(rawValue)\"".utf8))
        }
    }

    @Test("an unknown kind is refused")
    func unknownKindIsRefused()
    {
        #expect(SemanticBlockKind(rawValue: "footnote") == nil)
        let data = Data(#""footnote""#.utf8)
        #expect(throws: DecodingError.self)
        {
            try JSONDecoder().decode(
                SemanticBlockKind.self,
                from: data
            )
        }
    }

    private func expectedRawValue(
        for kind: SemanticBlockKind
    ) -> String
    {
        switch kind
        {
        case .paragraph:
            "paragraph"
        case .heading:
            "heading"
        case .quote:
            "quote"
        case .code:
            "code"
        case .listItem:
            "listItem"
        case .sceneBreak:
            "sceneBreak"
        case .table:
            "table"
        case .image:
            "image"
        case .rawHTML:
            "rawHTML"
        }
    }
}
