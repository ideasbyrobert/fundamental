import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticRunTests
{
    @Test("required flat fields decode and malformed values are refused")
    func requiredFlatFieldsDecodeAndMalformedValuesAreRefused() throws
    {
        let payload = Data(
            #"""
            {"text":"Body",
            "traits":["strong","emphasis","strong"],
            "future":true}
            """#.utf8
        )
        let decoded = try JSONDecoder().decode(
            SemanticRun.self,
            from: payload
        )

        #expect(decoded == SemanticRun(
            text: "Body",
            traits: [.strong, .emphasis]
        ))

        let invalidPayloads = [
            Data(#"{"traits":[]}"#.utf8),
            Data(#"{"text":"Body"}"#.utf8),
            Data(#"{"text":null,"traits":[]}"#.utf8),
            Data(#"{"text":1,"traits":[]}"#.utf8),
            Data(#"{"text":"Body","traits":null}"#.utf8),
            Data(#"{"text":"Body","traits":{}}"#.utf8),
            Data(#"{"text":"Body","traits":["bold"]}"#.utf8)
        ]
        for invalidPayload in invalidPayloads
        {
            #expect(throws: DecodingError.self)
            {
                try JSONDecoder().decode(
                    SemanticRun.self,
                    from: invalidPayload
                )
            }
        }
    }
}
