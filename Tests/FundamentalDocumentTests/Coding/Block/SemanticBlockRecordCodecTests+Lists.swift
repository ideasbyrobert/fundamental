import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticBlockRecordCodecTests
{
    @Test("list records preserve both kinds without generated marker text")
    func listRecords() throws
    {
        for kind in SemanticListKind.allCases
        {
            let block = SemanticBlock.listItem(SemanticListItem(
                kind: kind, runs: []
            ))
            let bytes = try SemanticBlockRecordCodec.encode(block)
            let expected = "{\"kind\":\"listItem\",\"listKind\":\"" +
                kind.rawValue + "\",\"runs\":[]}\n"
            #expect(bytes == Data(expected.utf8))
            #expect(try SemanticBlockRecordCodec.decode(bytes) == block)
        }
    }

    @Test("unknown missing mistyped and extra list fields refuse")
    func malformedLists() throws
    {
        let base: [String: Any] = [
            "kind": "listItem", "listKind": "numbered", "runs": []
        ]
        var cases: [[String: Any]] = []
        for value: Any in ["task", "Numbered", 1, true, NSNull()]
        {
            var changed = base
            changed["listKind"] = value
            cases.append(changed)
        }
        var missing = base
        missing.removeValue(forKey: "listKind")
        cases.append(missing)
        var extra = base
        extra["ordinal"] = 1
        cases.append(extra)
        for object in cases
        {
            let bytes = try JSONSerialization.data(withJSONObject: object)
            #expect(throws: (any Error).self)
            {
                try SemanticBlockRecordCodec.decode(bytes)
            }
        }
    }
}
