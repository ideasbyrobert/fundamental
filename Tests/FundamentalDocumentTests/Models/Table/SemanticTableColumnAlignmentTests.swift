import Foundation
import Testing

@testable import FundamentalDocument

@Suite("The semantic table column alignments")
struct SemanticTableColumnAlignmentTests
{
    private let alignments: [SemanticTableColumnAlignment] = [
        .leading,
        .center,
        .trailing,
        .unspecified
    ]

    @Test("the compatibility vocabulary and raw values are exact")
    func vocabularyIsExact()
    {
        #expect(alignments.count == 4)
        for alignment in alignments
        {
            let rawValue = expectedRawValue(for: alignment)
            #expect(alignment.rawValue == rawValue)
            #expect(
                SemanticTableColumnAlignment(rawValue: rawValue)
                    == alignment
            )
        }
    }

    @Test("every alignment has a deterministic Codable round trip")
    func alignmentsRoundTrip() throws
    {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for alignment in alignments
        {
            let rawValue = expectedRawValue(for: alignment)
            let data = try encoder.encode(alignment)
            let decoded = try decoder.decode(
                SemanticTableColumnAlignment.self,
                from: data
            )
            #expect(decoded == alignment)
            #expect(data == Data("\"\(rawValue)\"".utf8))
        }
    }

    @Test("physical and inferred spellings are refused")
    func unsupportedSpellingsAreRefused()
    {
        for rawValue in ["left", "right", "natural"]
        {
            #expect(
                SemanticTableColumnAlignment(rawValue: rawValue) == nil
            )
            let data = Data("\"\(rawValue)\"".utf8)
            #expect(throws: DecodingError.self)
            {
                try JSONDecoder().decode(
                    SemanticTableColumnAlignment.self,
                    from: data
                )
            }
        }
    }

    private func expectedRawValue(
        for alignment: SemanticTableColumnAlignment
    ) -> String
    {
        switch alignment
        {
        case .leading:
            "leading"
        case .center:
            "center"
        case .trailing:
            "trailing"
        case .unspecified:
            "unspecified"
        }
    }
}
