import Foundation
import Testing

@testable import FundamentalDocument

@Suite("Canonical writing block styles")
struct CanonicalBlockStyleTests
{
    @Test("the admitted vocabulary is exact and ordered")
    func vocabularyIsExact()
    {
        #expect(CanonicalBlockStyle.allCases == [
            .title,
            .heading1,
            .heading,
            .subheading,
            .heading4,
            .heading5,
            .heading6,
            .body,
            .monostyled,
            .bulleted,
            .numbered
        ])
        #expect(CanonicalBlockStyle.allCases.map(\.rawValue) == [
            "title",
            "heading1",
            "heading",
            "subheading",
            "heading4",
            "heading5",
            "heading6",
            "body",
            "monostyled",
            "bulleted",
            "numbered"
        ])
    }

    @Test("every admitted style has a deterministic Codable round trip")
    func admittedStylesRoundTrip() throws
    {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for style in CanonicalBlockStyle.allCases
        {
            let data = try encoder.encode(style)
            let decoded = try decoder.decode(
                CanonicalBlockStyle.self,
                from: data
            )
            #expect(decoded == style)
            #expect(data == Data("\"\(style.rawValue)\"".utf8))
        }
    }

    @Test("an unknown raw value is refused")
    func unknownRawValueIsRefused()
    {
        let data = Data(#""quote""#.utf8)
        #expect(throws: DecodingError.self)
        {
            try JSONDecoder().decode(
                CanonicalBlockStyle.self,
                from: data
            )
        }
    }
}
