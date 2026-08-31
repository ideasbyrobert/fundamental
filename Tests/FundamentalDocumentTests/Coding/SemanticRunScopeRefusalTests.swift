import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticRunTests
{
    @Test("wrong scope types are refused")
    func wrongScopeTypesAreRefused()
    {
        let invalidPayloads = [
            Data(#"{"text":"Body","traits":[],"link":1}"#.utf8),
            Data(#"{"text":"Body","traits":[],"language":false}"#.utf8)
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
