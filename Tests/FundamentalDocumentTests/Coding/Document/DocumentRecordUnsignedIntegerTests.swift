import Foundation
import Testing

@testable import FundamentalDocument

@Suite("Exact document record integers")
struct DocumentRecordUnsignedIntegerTests
{
    @Test("unsigned integer literals retain all sixty four bits")
    func exactUnsignedValues() throws
    {
        for integer in [UInt64(0), 1, 9_007_199_254_740_993, UInt64.max]
        {
            let value = try JSONSerialization.jsonObject(
                with: Data(String(integer).utf8),
                options: .fragmentsAllowed
            )
            #expect(try DocumentRecordUnsignedInteger.decode(
                value,
                path: ["revision"]
            ) == integer)
        }
    }

    @Test("booleans floats negatives strings and overflow refuse integer roles")
    func invalidUnsignedValues() throws
    {
        let values = [
            "true", "false", "-1", "1.0", "1e0", "1.5", "\"1\"", "null",
            "9007199254740993.0", "18446744073709551616", "1e40"
        ]
        for literal in values
        {
            let value = try JSONSerialization.jsonObject(
                with: Data(literal.utf8),
                options: .fragmentsAllowed
            )
            #expect(throws: DecodingError.self)
            {
                try DocumentRecordUnsignedInteger.decode(
                    value,
                    path: ["revision"]
                )
            }
        }
    }
}
