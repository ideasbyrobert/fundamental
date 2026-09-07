import Foundation
import Testing

@testable import FundamentalDocument

extension DocumentRecordCodecTests
{
    @Test("a complete semantic document round trips with version two")
    func semanticListRecord() throws
    {
        let runs = try BlockRecordTestValue.runs()
        let styles: [CanonicalBlockStyle] = [
            .title, .heading, .body, .bulleted,
            .numbered, .numbered, .subheading
        ]
        let source = try DocumentRecordTestValue.document(
            blocks: styles.map { $0.semanticBlock(runs: runs) }
        )
        let codec = DocumentRecordTestValue.codec
        let bytes = try codec.encode(source)
        let object = try #require(JSONSerialization.jsonObject(
            with: bytes
        ) as? [String: Any])
        #expect(object["version"] as? Int == 2)
        let restored = try codec.decode(bytes)
        #expect(restored == source)
        #expect(try codec.encode(restored) == bytes)
        for block in restored.content.blocks
        {
            let actual = try #require(EditableSemanticBlock(block.block)).runs
            for (before, after) in zip(runs, actual)
            {
                #expect(Array(before.text.utf16) == Array(after.text.utf16))
            }
        }
    }

    @Test("list free content retains the exact legacy version one encoding")
    func minimumVersion() throws
    {
        let codec = DocumentRecordTestValue.codec
        let legacy = try codec.encode(DocumentRecordTestValue.plain())
        var object = try DocumentRecordTestValue.object()
        object["version"] = 2
        let restored = try codec.decode(DocumentRecordTestValue.bytes(object))
        #expect(try codec.encode(restored) == legacy)
    }

    @Test("legacy and unknown envelopes refuse newly encoded list records")
    func invalidListVersion() throws
    {
        let source = try SemanticWritingTestDocument([.numbered])
        let codec = DocumentRecordTestValue.codec
        var object = try #require(JSONSerialization.jsonObject(
            with: codec.encode(source.document)
        ) as? [String: Any])
        for version in [0, 1, 3]
        {
            object["version"] = version
            #expect(throws: (any Error).self)
            {
                try codec.decode(DocumentRecordTestValue.bytes(object))
            }
        }
    }
}
