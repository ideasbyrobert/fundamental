import Foundation
import Testing

@testable import FundamentalDocument

@Suite("Owned document admission refusals")
struct DocumentRecordFailureTests
{
    @Test("foreign formats and future versions are refused distinctly")
    func formatAndVersionRefusals() throws
    {
        var object = try DocumentRecordTestValue.object()
        object["format"] = "other-document"
        let foreign = try DocumentRecordTestValue.bytes(object)
        #expect(throws: DocumentRecordFailure.unsupportedFormat)
        {
            try DocumentRecordTestValue.codec.decode(foreign)
        }
        object["format"] = "fundamental-document"
        object["version"] = UInt64.max
        object["futureField"] = true
        let future = try DocumentRecordTestValue.bytes(object)
        #expect(throws: DocumentRecordFailure.unsupportedVersion(UInt64.max))
        {
            try DocumentRecordTestValue.codec.decode(future)
        }
    }

    @Test("empty content and repeated block identities cannot become documents")
    func canonicalContentRefusals() throws
    {
        var object = try DocumentRecordTestValue.object()
        let entries = try #require(object["blocks"] as? [[String: Any]])
        for blocks in [[], entries + entries]
        {
            object["blocks"] = blocks
            let bytes = try DocumentRecordTestValue.bytes(object)
            #expect(throws: DocumentRecordFailure.invalidContent)
            {
                try DocumentRecordTestValue.codec.decode(bytes)
            }
        }
    }
}
