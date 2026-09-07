import Foundation
import Testing

@testable import FundamentalDocument

@Suite("Canonical block records")
struct SemanticBlockRecordCodecTests
{
    @Test("literal paragraphs establish exact canonical bytes")
    func literalParagraphBytes() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            SemanticRun(text: "Հայերեն e\u{301}", traits: [.strong, .emphasis])
        ]))
        let expected = #"{"kind":"paragraph","runs":[{"text":"Հայերեն é","#
            + #""traits":["emphasis","strong"]}]}"# + "\n"
        let encoded = try SemanticBlockRecordCodec.encode(block)
        #expect(encoded == Data(expected.utf8))
        let decoded = try SemanticBlockRecordCodec.decode(Data(expected.utf8))
        #expect(decoded == block)
    }

    @Test("every canonical block distinction survives stable records")
    func everyBlockRoundTrips() throws
    {
        for block in try BlockRecordTestValue.blocks()
        {
            let first = try SemanticBlockRecordCodec.encode(block)
            let restored = try SemanticBlockRecordCodec.decode(first)
            #expect(restored == block)
            #expect(try SemanticBlockRecordCodec.encode(restored) == first)
        }
    }

    @Test("equal looking Unicode retains its exact scalar spelling")
    func unicodeSpellingSurvives() throws
    {
        let runs = try BlockRecordTestValue.runs()
        let input = SemanticBlock.paragraph(SemanticParagraph(runs: runs))
        let bytes = try SemanticBlockRecordCodec.encode(input)
        let decoded = try SemanticBlockRecordCodec.decode(bytes)
        guard case let .paragraph(paragraph) = decoded
        else
        {
            Issue.record("Expected an intact paragraph")
            return
        }
        #expect(paragraph.runs.count == runs.count)
        for (before, after) in zip(runs, paragraph.runs)
        {
            #expect(before.text.utf8.elementsEqual(after.text.utf8))
        }
    }

    @Test("object order and insignificant whitespace do not change meaning")
    func reorderedInputRetainsMeaning() throws
    {
        let bytes = Data(" \n{\"runs\":[],\"kind\":\"title\"}\t".utf8)
        let block = try SemanticBlockRecordCodec.decode(bytes)
        #expect(block == .heading(.title(TitleSemanticHeading(runs: []))))
        let expected = Data("{\"kind\":\"title\",\"runs\":[]}\n".utf8)
        #expect(try SemanticBlockRecordCodec.encode(block) == expected)
    }
}
