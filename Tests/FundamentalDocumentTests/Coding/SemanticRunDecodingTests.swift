import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticRunTests
{
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
}
