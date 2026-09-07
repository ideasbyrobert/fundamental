import Foundation
import Testing

@testable import FundamentalDocument

@Suite("Bounded owned document coding")
struct DocumentRecordCodecTests
{
    @Test("revision extremes survive without floating point rounding")
    func exactRevisions() throws
    {
        let codec = DocumentRecordTestValue.codec
        for revision in [UInt64(0), 9_007_199_254_740_993, UInt64.max]
        {
            let document = try DocumentRecordTestValue.document(
                blocks: [.paragraph(SemanticParagraph(runs: []))],
                revision: revision
            )
            let reopened = try codec.decode(codec.encode(document))
            #expect(reopened.revision.value == revision)
            #expect(reopened == document)
        }
    }

    @Test("document array order remains canonical even with stable IDs")
    func blockOrderIsPreserved() throws
    {
        let blocks = try BlockRecordTestValue.blocks()
        let document = try DocumentRecordTestValue.document(blocks: blocks)
        let codec = DocumentRecordTestValue.codec
        var object = try #require(JSONSerialization.jsonObject(
            with: codec.encode(document)
        ) as? [String: Any])
        let entries = try #require(object["blocks"] as? [[String: Any]])
        object["blocks"] = Array(entries.reversed())
        let reopened = try codec.decode(DocumentRecordTestValue.bytes(object))
        #expect(reopened.content.blocks == document.content.blocks.reversed())
    }

    @Test("encoding preserves raw Unicode across complete document records")
    func exactRunBytes() throws
    {
        let runs = try BlockRecordTestValue.runs()
        let document = try DocumentRecordTestValue.document(blocks: [
            .paragraph(SemanticParagraph(runs: runs))
        ])
        let codec = DocumentRecordTestValue.codec
        let reopened = try codec.decode(codec.encode(document))
        guard case let .paragraph(paragraph) = reopened.content.blocks[0].block
        else
        {
            Issue.record("Expected the unchanged paragraph")
            return
        }
        #expect(paragraph.runs.count == runs.count)
        for (before, after) in zip(runs, paragraph.runs)
        {
            #expect(before.text.utf8.elementsEqual(after.text.utf8))
        }
    }
}
