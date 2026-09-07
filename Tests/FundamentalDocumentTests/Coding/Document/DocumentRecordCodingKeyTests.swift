import Testing

@testable import FundamentalDocument

@Suite("Owned record coding paths")
struct DocumentRecordCodingKeyTests
{
    @Test("field and index keys retain their diagnostic spelling")
    func fieldsAndIndicesRetainSpelling()
    {
        let field = DocumentRecordCodingKey("documentID")
        let index = DocumentRecordCodingKey(intValue: 17)
        #expect(field.stringValue == "documentID")
        #expect(field.intValue == nil)
        #expect(index?.stringValue == "17")
        #expect(index?.intValue == 17)
        #expect(DocumentRecordCodingKey(stringValue: "runs")?.intValue == nil)
    }
}
