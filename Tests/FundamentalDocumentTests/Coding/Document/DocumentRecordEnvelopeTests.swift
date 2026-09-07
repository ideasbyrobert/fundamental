import Foundation
import Testing

@testable import FundamentalDocument

@Suite("Complete owned document envelopes")
struct DocumentRecordEnvelopeTests
{
    @Test("literal bytes establish the complete durable document format")
    func literalEnvelope() throws
    {
        let literal = #"{"blocks":[{"blockID":"00000000-0000-0000-0000-"#
            + #"000000000002","content":{"kind":"paragraph","runs":[{"#
            + #""text":"A","traits":[]}]}}],"documentID":"#
            + #""00000000-0000-0000-0000-000000000001","#
            + #""format":"fundamental-document","revision":8,"version":1}"#
            + "\n"
        let document = try DocumentRecordTestValue.plain()
        let bytes = Data(literal.utf8)
        let codec = DocumentRecordTestValue.codec
        #expect(try codec.encode(document) == bytes)
        #expect(try codec.decode(bytes) == document)
    }

    @Test("envelopes retain ordered identities beyond native session state")
    func completeIdentityAndContent() throws
    {
        let blocks = try BlockRecordTestValue.blocks()
        let document = try DocumentRecordTestValue.document(blocks: blocks)
        let codec = DocumentRecordTestValue.codec
        let bytes = try codec.encode(document)
        let reopened = try codec.decode(bytes)
        #expect(reopened.documentID == document.documentID)
        #expect(reopened.revision == document.revision)
        #expect(reopened.content.blocks == document.content.blocks)
        #expect(try codec.encode(reopened) == bytes)
    }
}
