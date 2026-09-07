import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticBlockRecordCodecTests
{
    @Test("literal tags retain each textual block form")
    func literalTextualKinds() throws
    {
        let language = try #require(SemanticCodeLanguageIdentifier("swift"))
        let cases: [(String, SemanticBlock)] = [
            (#"{"kind":"paragraph","runs":[]}"#,
             .paragraph(SemanticParagraph(runs: []))),
            (#"{"kind":"title","runs":[]}"#,
             .heading(.title(TitleSemanticHeading(runs: [])))),
            (#"{"kind":"section","level":1,"runs":[]}"#,
             .heading(.section(SectionSemanticHeading(runs: [], level: .one)))),
            (#"{"kind":"code","runs":[]}"#,
             .code(.plain(PlainSemanticCodeBlock(runs: [])))),
            (#"{"kind":"languageCode","language":"swift","runs":[]}"#,
             .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: [],
                language: language
             ))))
        ]
        for (literal, block) in cases
        {
            let bytes = Data((literal + "\n").utf8)
            #expect(try SemanticBlockRecordCodec.decode(bytes) == block)
            #expect(try SemanticBlockRecordCodec.encode(block) == bytes)
        }
    }

    @Test("literal tables retain the nested canonical record")
    func literalTableKind() throws
    {
        let content = try #require(SemanticTableContent(
            headerRows: [],
            bodyRows: [],
            columnAlignments: []
        ))
        let block = SemanticBlock.table(.semantic(.regular(
            RegularSemanticTable(content: content)
        )))
        let literal = #"{"kind":"table","table":{"record":"semantic","#
            + #""table":{"content":{"bodyRows":[],"columnAlignments":[],"#
            + #""headerRows":[]},"kind":"regular"}}}"# + "\n"
        let bytes = Data(literal.utf8)
        #expect(try SemanticBlockRecordCodec.decode(bytes) == block)
        #expect(try SemanticBlockRecordCodec.encode(block) == bytes)
    }
}
