import Foundation
import Testing

@testable import FundamentalDocument

extension DocumentRecordCodecTests
{
    @Test("owned roots refuse unknown missing and malformed members")
    func rootShapeRefusal() throws
    {
        let original = try DocumentRecordTestValue.object()
        var cases = original.keys.map
        {
            key in
            var changed = original
            changed.removeValue(forKey: key)
            return changed
        }
        var extra = original
        extra["selection"] = 0
        cases.append(extra)
        for key in ["documentID", "revision", "blocks"]
        {
            var changed = original
            changed[key] = "invalid"
            cases.append(changed)
        }
        for object in cases
        {
            let bytes = try DocumentRecordTestValue.bytes(object)
            #expect(throws: (any Error).self)
            {
                try DocumentRecordTestValue.codec.decode(bytes)
            }
        }
    }

    @Test("block entry errors cannot manufacture a partial document")
    func malformedBlockEntriesRefuse() throws
    {
        var root = try DocumentRecordTestValue.object()
        let entries = try #require(root["blocks"] as? [[String: Any]])
        let first = try #require(entries.first)
        let malformed: [[String: Any]] = [
            ["blockID": "invalid", "content": first["content"]!],
            ["blockID": first["blockID"]!, "content": NSNull()],
            ["blockID": first["blockID"]!],
            ["blockID": first["blockID"]!, "content": first["content"]!,
             "unknown": true]
        ]
        for entry in malformed
        {
            root["blocks"] = [first, entry]
            let bytes = try DocumentRecordTestValue.bytes(root)
            #expect(throws: (any Error).self)
            {
                try DocumentRecordTestValue.codec.decode(bytes)
            }
        }
    }
}
